#!/usr/bin/env ruby

require_relative 'game'
include Game

# Import game configuration with path to configuration file. This is the same as
# starting a new game.
gs = GameState.new(ARGF.filename)

Game.game_loop(gs)
