require_relative 'battle'
require_relative 'state'

dirs = %w[e w n s ne nw se sw]

def game_loop(gs)
	while true
		p = gs.player
		puts gs.map.mini_map(p.coord, 10)
		puts p.coord_str
		tokens = STDIN.gets.chomp.split(' ')
		coord_old = p.coord
		if tokens.size > 1
			puts "command unsupported"
		else
			cmd = tokens[0]
			case cmd
			when "q"
				break
			when "e"
				p.move(:east, gs.map)
			when "w"
				p.move(:west, gs.map)
			when "n"
				p.move(:north, gs.map)
			when "s"
				p.move(:south, gs.map)
			when "ne"
				p.move(:northeast, gs.map)
			when "nw"
				p.move(:northwest, gs.map)
			when "se"
				p.move(:southeast, gs.map)
			when "sw"
				p.move(:southwest, gs.map)
			when nil
				if !p.last_move_dir.nil?
					p.move(p.last_move_dir, gs.map)
				else
					puts "You stall in confusion."
				end
			else
				puts "You stall in confusion."
			end

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
end
