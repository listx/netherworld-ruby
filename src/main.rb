#!/usr/bin/env ruby

require_relative 'game'

# Import game configuration with path to configuration file. This is the same as
# starting a new game.
gs = GameState.new(ARGF.filename)

game_loop(gs)
