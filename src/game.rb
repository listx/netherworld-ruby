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

			puts gs.map.mini_map(p.coord, 10)
			puts p.coord_str

			tokens = STDIN.gets.chomp.split(' ')
			@cmd = tokens[0]

			if tokens.size > 0
				if DIRS.include?(@cmd)
					gs.last_command = @cmd
					go_if_ok(gs, @cmd)
				else
					case @cmd
					when "q"
						break
					else
						puts "You stall in confusion."
					end
				end
			else
				go_if_ok(gs, gs.last_command)
			end
		end
	end

	def go_if_ok(gs, str)
		p = gs.player
		coord_old = p.coord
		p.move(DIR_HASH[str], gs.map)
		if p.coord != coord_old
			r = gs.rng.roll(100)
			if r < 7
				puts "You enter a battle!!!"
				spawn_monsters(gs)
				battle_loop(gs)
			end
		end
	end
end
