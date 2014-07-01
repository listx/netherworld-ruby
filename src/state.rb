require_relative 'map'

class GameState
	attr_accessor :map
	def initialize(map)
		@map = map
	end
end
