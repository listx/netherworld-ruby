# We could write a generic method that takes a string and returns a tile symbol,
# but because we are always going to be dealing with "String -> tile symbol"
# conversion, we might as well extend the String class itself to have a
# 'to_tile' method.
class String
	def to_tile
		case self
		when ','
			Tile.new(:sand)
		when '*'
			Tile.new(:snow)
		when '~'
			Tile.new(:water)
		else
			Tile.new(:grass)
		end
	end
end

class Room
	@tile
	attr_reader :tile
	def initialize(tile)
		@tile = tile
	end
end

class Tile
	def initialize(t)
		@tile = t
	end
	def to_s
		case @tile
		when :grass
			"."
		when :sand
			","
		when :snow
			"*"
		else
			"~"
		end
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
	attr_reader :game_map_array
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
	def mini_map(coord, view_dist)
		if view_dist < 1
			raise "oops"
		end
		n = view_dist
		xCenter = coord[0]
		yCenter = coord[1]
		map_len = (n * 2) + 1
		map_range = (-view_dist..view_dist)
		# Generate a 2D array that is the size of the minimap, and populate this
		# array with relative coordinates (aka offsets); we will apply these
		# offsets to the actual coordinates of the player.
		mini = Array.new(map_len) {Array.new(map_len)}
		x = 0
		y = 0
		map_range.each do |yCoord|
			map_range.each do |xCoord|
				yNew = yCoord + yCenter
				xNew = xCoord + xCenter
				if in_range?([xNew, yNew], @range)
					room = @game_map_array[yCoord + yCenter][xCoord + xCenter]
				else
					room = nil
				end
				if !room.nil?
					mini[y][x] = [[xNew, yNew], room.tile.to_s]
				end
				x += 1
			end
			x = 0
			y += 1
		end
		str = []
		x = 0
		y = 0
		mini.reverse.each do |yLine|
			yLine.each do |room|
				if room.nil?
					str << "X"
				else
					if room[0] == coord
						str << "@"
					else
						str << room[1]
					end
				end
				x += 1
			end
			str << "\n"
			x = 0
			y += 1
		end
		str.join("")
	end
end

def in_range?(c1, mapRange)
	mapX = mapRange[0]
	mapY = mapRange[1]
	x = c1[0]
	y = c1[1]
	x >= 0 && x < mapX && y >= 0 && y < mapY
end
