class Player
	attr_accessor :coord
	attr_reader :last_move_dir
	@coord
	@last_move_dir = nil

	def initialize(coord)
		@coord = coord
	end

	def go_dir(direction)
		x = @coord[0]
		y = @coord[1]
		case direction
		when :east
			[x + 1, y]
		when :west
			[x - 1, y]
		when :north
			[x, y + 1]
		when :south
			[x, y - 1]
		when :northeast
			[x + 1, y + 1]
		when :northwest
			[x - 1, y + 1]
		when :southeast
			[x + 1, y - 1]
		when :southwest
			[x - 1, y - 1]
		else
			raise
		end
	end

	def go_dirs(directions)
		coord_new = @coord
		directions.each do |direction|
			coord_new = self.go_dir?(direction)
		end
		coord_new
	end

	def can_go_dir?(direction, game_map)
		coord_new = self.go_dir(direction)
		x = coord_new[0]
		y = coord_new[1]
		in_range?(coord_new, game_map.range)\
			&& !game_map.game_map_array[y][x].nil?
	end

	def move(direction, game_map)
		if self.can_go_dir?(direction, game_map)
#			puts "You go #{direction.to_s}."
			self.go_dir!(direction)
			@last_move_dir = direction
		else
			puts "You cannot go there."
			@last_move_dir = nil
		end
	end

	def coord_str
		str = "("
		str << @coord[0].to_s
		str << ","
		str << @coord[1].to_s
		str << ")"
		str
	end

	# Destructive modification of @coord.
	def go_dir!(direction)
		@coord = go_dir(direction)
	end

	def go_dirs!(directions)
		@coord = go_dirs(directions)
	end
end
