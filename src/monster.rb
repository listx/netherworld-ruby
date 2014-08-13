require_relative 'random.rb'
require_relative 'stats.rb'

class Monster
	attr_accessor :stats
	def initialize(rng)
		@stats = Stats.new({})
		hp = rng.roll(100)
		@stats.merge_exist!({health: hp})
	end
end
