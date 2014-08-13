require 'pp'

require_relative 'battle'
require_relative 'state'

module Game
	attr_accessor :cmd
	DIRS = %w[e w n s ne nw se sw]
	DIRS_LONG = %w[
		east
		west
		north
		south
		northeast
		northwest
		southeast
		southwest
	]
	DIR_HASH = DIRS.zip(DIRS_LONG.map {|dl| dl.to_sym}).to_h

	def game_loop(gs, keep_going)
		while keep_going
			if gs.replay && gs.input_history.empty?
				keep_going = false
				break
			end
			gs, keep_going = game_step(gs, keep_going)
		end
		gs
	end

	def game_step(gs, keep_going)
		p = gs.player
		pc = p.coord

		puts gs.game_map.mini_map(pc, 10)
		puts p.coord_str

		tokens = get_user_input(gs).split(' ')
		@cmd =\
			if tokens.size > 0
				tokens[0]
			elsif !gs.last_command.empty?
				gs.last_command
			else
				""
			end
		if DIRS.include?(@cmd)
			gs.last_command = @cmd
			go_if_ok(gs, @cmd)
			pc_ = gs.player.coord
			if (pc != pc_)
				mix_rng(gs, @cmd)
				battle_trigger(gs)
			end
		else
			case @cmd
			when "q", "quit"
				keep_going = false
			when "save"
				if tokens.size != 2
					puts "Please provide a single savegame filepath."
				else
					save_game(gs, tokens[1])
				end
			when "load"
				if tokens.size != 2
					puts "Please provide a single savegame filepath."
				else
					gs = load_game(tokens[1])
				end
			when ""
				puts "Confused already?"
			else
				puts "You stall in confusion."
			end
		end
		[gs, keep_going]
	end

	def go_if_ok(gs, str)
		p = gs.player
		coord_old = p.coord
		p.move(DIR_HASH[str], gs.game_map)
	end

	def mix_rng(gs, str)
		dir_rng_warmups = DIRS.zip(gs.rng.rnd_sample(8, (1..8).to_a)).to_h
		count = dir_rng_warmups[str]
		gs.rng.warmup(count)
	end

	def save_game(gs, f)
		if gs.replay
			return
		end
		str = []
		str << "map \"#{gs.config.game_map}\""
		str << "affix-db \"#{gs.config.affix_db}\""
		str << "monster-db \"#{gs.config.monster_db}\""
		str << ""
		str << "player-coord #{gs.player.coord[0]} #{gs.player.coord[1]}"
		str << "player-stats {"
		str << stats_to_text(gs.player.stats)
		str << "}"
		str << ""
		str << "last-command \"#{gs.last_command}\""
		str << ""
		str << "rng-initial"
		str << rng_to_text(gs.rng_initial)
		str << ""
		str << "rng"
		str << rng_to_text(gs.rng.state)
		str << ""
		str << "input-history #{gs.input_history}"
		IO.write(f, str.join("\n") + "\n")
	end

	def rng_to_text(w32s)
		w32s.map {|x| "0x%08x" % x.to_s}
			.each_slice(8)
			.to_a
			.map {|arr| "\t" + arr.join("\t")}
			.join("\n")
	end

	def stats_to_text(stats)
		stats
			.hash
			.flatten
			.each_slice(2)
			.to_a
			.map {|attr, val| "\t#{attr.capitalize} #{val}"}
	end

	def load_game(filepath)
		sg_hash = SaveGameParserTransform.new.apply(parse_savegame(filepath))
		# The first argument to GameConfig.new() is the empty string; we assume
		# (1) when the game starts, the configuration filepath is loaded in and
		# expanded to the full path and that (2) the full paths are saved into
		# the savegame file, so that when it is parsed for the map, affix_db,
		# etc. parameters, the filepaths are complete and ready to go as-is.
		game_config = GameConfig.new("", sg_hash[:game_config])
		game_state = game_state_from_config(game_config)
		player = Player.new(
			{ coord: sg_hash[:player][:coord]\
			, stats: Stats.new(sg_hash[:player][:stats].reduce(:merge))\
			}
		)
		# Change player's health, location, etc. to the one specified by the
		# savegame file. This is necessary because GameState initialization sets
		# the Player object to the default (i.e., "new game") settings.
		game_state.player = player
		game_state.last_command = sg_hash[:last_command]
		game_state.rng_initial = sg_hash[:rng_initial]
		game_state.rng = MWC256.new(:seed_mwc, sg_hash[:rng])
		game_state.input_history = sg_hash[:input_history]

		# Make copy of game state, but as if we are starting a new game of it
		game_state_copy = game_state.dup
		player_copy = Player.new(
			{ coord: game_state.game_map.first_coord\
			, stats: Stats.new({})\
			}
		)
		game_state_copy.player = player_copy
		game_state_copy.last_command = game_state.last_command.dup
		game_state_copy.rng = MWC256.new(:seed_manual, sg_hash[:rng_initial])
		game_state_copy.input_history = game_state.input_history.dup

		ok = verify_game(game_state, game_state_copy)
		if ok
			# When we parsed in the input history, we reversed it in
			# [LAST..FIRST] order, so that Array#pop would get the oldest
			# command first. Now that we've verified everything, we reverse it
			# again to [FIRST..LAST] order so that Array#push will *append* the
			# latest command to the end of the history.
			game_state.input_history = game_state.input_history.reverse
			pp game_state
			game_state
		else
			raise "game verification failure"
		end
	end

	def verify_game(gs, gs_copy)
		# game_loop through the input_history
		gs_copy.replay = true

		# Go through some sanity checks first; e.g., there has to be at least 1
		# command, which saved the game, which means input_history cannot be
		# empty.
		if gs_copy.input_history.empty?
			raise "input history is empty"
		end

		gs_copy = game_loop(gs_copy, true)

		if !rng_same_state(gs_copy.rng, gs.rng)
			puts "original savegame's rng:"
			p gs.rng_initial
			p gs.rng
			puts "replayed savegame's rng:"
			p gs_copy.rng_initial
			p gs_copy.rng
			raise "rng mismatch"
		elsif !player_same_state(gs_copy.player, gs.player)
			raise "player mismatch"
		else
			return true
		end
		return false
	end

	def parse_savegame(filepath)
		str = IO.read(filepath)
		parser = SaveGameParser.new
		parser.parse(str)
		rescue Parslet::ParseFailed => failure
			puts failure.cause.ascii_tree
	end

	class SaveGameParser < ConfigParser
		STATS_KEYS = %w[
			Health
			Mana
			Strength
			Wisdom
		]

		rule(:game_state) do
			game_config.as(:game_config) >>
				whitespace_ >>
				player.as(:player) >>
				last_command >>
				whitespace_ >> str('rng-initial') >> rng.as(:rng_initial) >>
				whitespace_ >> str('rng') >> rng.as(:rng) >>
				input_history.as(:input_history) >>
				whitespace_.maybe
		end

		rule(:player) do
			whitespace_.maybe >>
				player_coord >>
				player_stat
		end

		rule(:player_coord) do
			whitespace_.maybe >>
				str('player-coord') >>
				(whitespace_ >>
				integer.as(:integer)).repeat(2,2).as(:coord)
		end

		rule(:player_stat) do
			whitespace_.maybe >>
				str('player-stats') >>
				braces(stat.as(:stat).repeat(1)).as(:stats)

		end

		rule(:stat) do
			STATS_KEYS.map do |key|
				whitespace_.maybe >>
					str(key).as(:attr) >>
					whitespace_ >>
					integer.as(:integer)
			end.reduce(:|)
		end

		rule(:last_command) do
			whitespace_.maybe >>
				str("last-command") >>
				whitespace_ >>
				string_literal.as(:last_command)
		end

		rule(:rng) do
			(whitespace_.maybe >>
				str('0x') >>
				hex_single.repeat(8,8).as(:hex)).repeat(258,258).as(:hexes)
		end

		rule(:input_history) do
			whitespace_.maybe >>
				str('input-history') >>
				whitespace_ >>
				brackets(
					(string_literal >> str(',').maybe >> whitespace.maybe)
					.repeat(1).as(:input_history_array)
					)
		end

		root(:game_state)
	end
end

class SaveGameParserTransform < Parslet::Transform
	rule(stat: subtree(:x)) do
		{x[:attr].to_s.downcase.to_sym => x[:integer].to_s.to_i}
	end

	rule(hexes: subtree(:x)) do
		x.map {|h| h[:hex].to_s.to_i(16)}
	end

	rule(string_literal: simple(:x)) do
		String(x).unquote
	end

	rule(integer: simple(:x)) do
		String(x).to_i
	end

	# For NW-r, we reverse the data structure, because we use Array#push and
	# Array#pop for manipulating it; these methods add and subtract the *last*
	# element in an array. In Haskell, we use the cons (:) operator, which deal
	# with pattern matching against the *first* element in the list.
	rule(input_history_array: sequence(:x)) do
		x.reverse
	end
end
