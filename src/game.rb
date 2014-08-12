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

			tokens = STDIN.gets.chomp.split(' ')
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
end
