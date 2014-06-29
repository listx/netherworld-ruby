#!/usr/bin/env ruby

# We could write a generic method that takes a string and returns a tile symbol,
# but because we are always going to be dealing with "String -> tile symbol"
# conversion, we might as well extend the String class itself to have a
# 'to_tile' method.
class String
	def to_tile
		case self
		when ','
			:sand
		when '*'
			:snow
		when '~'
			:water
		else
			:grass
		end
	end
end

class Room
	@tile = :grass
	attr_reader :tile
	def initialize(tile)
		@tile = tile
	end
end

class GameMap
	@tile_hash =\
		{ grass: '.'\
		, sand: ','\
		, snow: '*'\
		, water: '~'\
		}
	@range = [0, 0]
	attr_reader :range
	def initialize(filename)
		# read and put lines of given filename into array
		lines = IO.readlines(filename)
		# Determine the map size.
		x = 0
		x_max = 0
		lines.reverse.each do |line|
			x = line.chomp.size
			if x_max < x
				x_max = x
			end
		end
		@game_map_array = Array.new(lines.size) {Array.new(x_max)}
		@range = [x_max, lines.size]

		# Make note of each room defined by the map.
		x = 0
		y = 0
		lines.reverse.each do |line|
			line.chomp.each_char do |c|
				case c
				when " "
					@game_map_array[y][x] = nil
				else
					@game_map_array[y][x] = Room.new(c.to_tile)
				end
				x += 1
			end
			if x_max < x
				x_max = x
			end
			x = 0
			y += 1
		end
	end
	def mini_map(coordinate)
		"a string representation of the (entire?) game map..."
	end
end
