#!/usr/bin/env ruby
require 'pp'

require_relative 'game'
require_relative 'option'

# Allow calling Game module methods with `Game.` prefix.
include Game

# Import game configuration with path to configuration file. This is the same as
# starting a new game.
opt_parsed = OptparseNW.new(ARGV)
opt_parsed.args_check

cfg = config_from_filepath(opt_parsed.options.game_cfg)
gs = game_state_from_config(cfg)
gs.debug = opt_parsed.options.debug
gs.player = Player.new({coord: gs.game_map.first_coord, stats: Stats.new({})})

Game.game_loop(gs, true)
