require_relative 'affix'
require_relative 'config'
require_relative 'map'
require_relative 'random'

class GameState
	attr_accessor :map
	attr_accessor :monsters
	attr_accessor :affix_db
	attr_accessor :rng
	attr_accessor :last_command
	attr_accessor :last_battle_command
	def initialize(config)
		@map = GameMap.new(config.map)
		@affix_db = AffixParserTransform.new.apply(parse_affix_db(config.affix_db))
		@monsters = []
		@rng = MWC256.new(:seed_manual, (1..258).to_a)
		@last_command = ""
		@last_battle_command = ""
	end
end
