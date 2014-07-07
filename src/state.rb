require_relative 'map'

class GameState
	attr_accessor :map
	attr_accessor :monsters
	attr_accessor :rng
	attr_accessor :last_command
	attr_accessor :last_battle_command
	def initialize(map)
		@map = map
		@monsters = []
		@rng = Random.new
		@last_command = ""
		@last_battle_command = ""
	end
end
