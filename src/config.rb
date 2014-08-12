require 'parslet'
require 'pathname'

require_relative 'util'

class GameConfig
	attr_accessor :game_map
	attr_accessor :affix_db
	attr_accessor :monster_db

	def initialize(filename)
		# First, get the location of the configuration file; as the entries
		# *inside* the config file will have paths, we must relativize these
		# paths with respect to the config file's own path.
		config_path = Pathname.new(filename)
		config_dir = config_path.dirname

		config_raw = IO.read(filename)
		hash = ConfigParserTransform.new.apply(parse_config(config_raw))
		@game_map = config_dir + hash[:map]
		@affix_db = config_dir + hash[:affix_db]
		@monster_db = config_dir + hash[:monster_db]
	end
end

GCONF_KEYS = %w[
	map
	affix-db
	monster-db
	]

class ConfigParser < ParserHelpers
	# Enumerable#reduce(:method_name) calls method_name() on all arguments to
	# reduce it; e.g., (5..10).reduce(:+) gets us 45
	rule(:game_config) do
		GCONF_KEYS.map do |key|
			whitespace_.maybe >>
				str(key) >>
				whitespace_.maybe >>
				string_literal.as(no_dash(key).to_sym) >>
				whitespace_.maybe
		end.reduce(:>>)
	end

	# Specify master rule to start parsing from.
	root(:game_config)
end

def parse_config(str)
	gconf = ConfigParser.new

	gconf.parse(str)
	rescue Parslet::ParseFailed => failure
		puts failure.cause.ascii_tree
end

class ConfigParserTransform < Parslet::Transform
	rule(string_literal: simple(:x)) do
		String(x)
	end
end
