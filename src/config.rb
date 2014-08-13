require 'parslet'
require 'pathname'

require_relative 'util'

class GameConfig
	attr_accessor :game_map
	attr_accessor :affix_db
	attr_accessor :monster_db

	def initialize(config_dir, config_hash)
		# First, get the location of the configuration file; as the entries
		# *inside* the config file will have paths, we must relativize these
		# paths with respect to the config file's own path.
		@game_map = config_dir + config_hash[:map]
		@affix_db = config_dir + config_hash[:affix_db]
		@monster_db = config_dir + config_hash[:monster_db]
	end
end

def config_from_filepath(config_fp)
	config_path = Pathname.new(config_fp)
	config_dir = config_path.dirname
	config_raw = IO.read(config_fp)
	config_hash = ConfigParserTransform.new
		.apply(parse_config(config_raw))
	GameConfig.new(config_dir, config_hash)
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
				string_literal.as(key.undash.to_sym) >>
				whitespace_.maybe
		end.reduce(:>>)
	end

	# Specify master rule to start parsing from.
	root(:game_config)
end

def parse_config(str)
	parser = ConfigParser.new

	parser.parse(str)
	rescue Parslet::ParseFailed => failure
		puts failure.cause.ascii_tree
end

class ConfigParserTransform < Parslet::Transform
	rule(string_literal: simple(:x)) do
		String(x).unquote
	end
end
