class Player
	attr_accessor :coord
	attr_accessor :stats
	@coord

	def initialize(player_hash)
		@coord = player_hash[:coord]
		@stats = player_hash[:stats]
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
			raise "invalid direction"
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

	def move(gs, direction, game_map)
		if self.can_go_dir?(direction, game_map)
			self.go_dir!(direction)
		else
			nw_puts(gs, "You cannot go there.")
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

def player_same_state(p1, p2)
	(p1.coord == p2.coord)\
		&& stats_same_state(p1.stats, p2.stats)
end
