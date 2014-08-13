#!/usr/bin/env ruby

require_relative 'game'
include Game

# Import game configuration with path to configuration file. This is the same as
# starting a new game.
cfg = config_from_filepath(ARGF.filename)
gs = game_state_from_config(cfg)
gs.player = Player.new({coord: gs.game_map.first_coord, stats: Stats.new({})})

Game.game_loop(gs, true)
