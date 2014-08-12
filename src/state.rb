require_relative 'affix'
require_relative 'config'
require_relative 'map'
require_relative 'player'
require_relative 'random'

class GameState
	attr_accessor :config
	attr_accessor :game_map
	attr_accessor :player
	attr_accessor :monsters
	attr_accessor :last_command
	attr_accessor :last_battle_command
	attr_accessor :affix_db
	attr_accessor :monster_db
	attr_accessor :rng
	attr_accessor :rng_initial
	attr_accessor :input_history
	attr_accessor :replay
	attr_accessor :debug
	def initialize(f)
		@config = GameConfig.new(f)
		@game_map = GameMap.new(@config.game_map)
		@player = Player.new(@game_map.first_coord)
		@affix_db = \
			AffixParserTransform.new.apply(parse_affix_db(@config.affix_db))
		@monsters = []
		@rng = MWC256.new(:seed_manual, (1..258).to_a)
		@rng_initial = MWC256.new(:seed_mwc, (1..258).to_a)
		@last_command = ""
		@last_battle_command = ""
		@input_history = []
		@replay = false
		@debug = false
	end

end

def get_user_input(gs)
	if gs.replay
		gs.input_history.pop
	else
		str = STDIN.gets.chomp
		gs.input_history.push(str)
		str
	end
end
