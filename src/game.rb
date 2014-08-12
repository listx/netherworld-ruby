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

	def game_loop(gs)
		while true
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
					break
				when "save"
					if tokens.size != 2
						puts "Please provide a single savegame filepath."
					else
						save_game(gs, tokens[1])
					end
				when ""
					puts "Confused already?"
				else
					puts "You stall in confusion."
				end
			end
		end
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
		str << stats_to_text(gs.player)
		str << "}"
		str << ""
		str << "last-command \"#{gs.last_command}\""
		str << ""
		str << "rng-initial"
		str << rng_to_text(gs.rng_initial)
		str << ""
		str << "rng"
		str << rng_to_text(gs.rng)
		str << ""
		str << "input-history #{gs.input_history}"
		IO.write(f, str.join("\n") + "\n")
	end

	def rng_to_text(rng)
		rng
			.state
			.to_a
			.map {|x| "0x%08x" % x.to_s}
			.each_slice(8)
			.to_a
			.map {|arr| "\t" + arr.join("\t")}
			.join("\n")
	end

	def stats_to_text(player)
		player
			.stats
			.hash
			.map {|attr, val| "\t#{attr.to_s.capitalize} #{val.to_s}"}
	end
end
