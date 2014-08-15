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
	attr_accessor :rng_initial
	attr_accessor :rng
	attr_accessor :input_history
	attr_accessor :replay
	attr_accessor :debug
	def initialize(hash)
		@config = hash[:game_config]
		@game_map = GameMap.new(hash[:game_map_lines])
		player_hash = {coord: @game_map.first_coord, stats: []}
		@player = Player.new(player_hash)
		@affix_db = \
			AffixParserTransform.new
			.apply(parse_affix_db(@config.affix_db))
		@monsters = []
		@rng_initial = hash[:rng_initial_w32s]
		@rng = \
			MWC256.new(:seed_manual, hash[:rng_initial_w32s])
		@last_command = ""
		@last_battle_command = ""
		@input_history = []
		@replay = false
		@debug = false
	end
end

# Create a 'default' game state, based on a GameConfig object.
def game_state_from_config(game_config)
	gs_hash = {}
	gs_hash.store(:game_config, game_config)
	game_map_lines = IO.readlines(game_config.game_map)
	gs_hash.store(:game_map_lines, game_map_lines)
	gs_hash.store(:rng_w32s, (1..258).to_a)
	gs_hash.store(:rng_initial_w32s, (1..258).to_a)
	GameState.new(gs_hash)
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

def nw_puts(gs, str)
	if !gs.replay || gs.debug
		puts str
	end
end
