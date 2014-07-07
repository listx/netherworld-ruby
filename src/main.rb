#!/usr/bin/env ruby

require_relative 'battle'
require_relative 'map'
require_relative 'player'
require_relative 'random'
require_relative 'state'

# Import map.
g = GameMap.new(ARGF.filename)
gs = GameState.new(g)
p = Player.new([0, 0])

while true
	puts gs.map.mini_map(p.coord, 10)
	puts p.coord_str
	cmd = STDIN.gets.chomp
	coord_old = p.coord
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
	when ""
		if !p.last_move_dir.nil?
			p.move(p.last_move_dir, gs.map)
		else
			puts "You stall in confusion."
		end
	else
		puts "You stall in confusion."
	end

	case cmd
	when "e", "w", "n", "s"
		if p.coord != coord_old
			r = roll(gs.rng, 100)
			if r < 100
				puts "You enter a battle!!!"
				spawn_monsters(gs)
				battle_loop(gs)
			end
		end
	end
end
