require 'optparse'
require 'optparse/time'
require 'ostruct'
require 'pp'

require_relative 'error'
require_relative 'meta'
include Meta

class OptparseNW

	attr_accessor :options

	# Return a structure describing the options.
	def initialize(argv)
		# The options specified on the command line will be collected in
		# *options*.
		# We set default values here.
		@options = OpenStruct.new
		@options.game_cfg = ""
		@options.debug = false

		opt_parser = OptionParser.new do |opts|
			opts.banner = Meta::PROG_INFO + ", " + Meta::COPYRIGHT
			opts.separator ""
			opts.separator "NetherWorld-Ruby [OPTIONS]"
			opts.separator "    " + Meta::PROG_SUMMARY
			opts.separator ""
			opts.separator "Common flags:"

			# Boolean switch.
			opts.on_tail("-d", "--debug-mode", "enable Debug mode") do |d|
				@options.verbose = d
			end

			# Mandatory argument.
			opts.on_tail("-g",
					"--game-cfg GAME_CONFIG",
					"Load GAME_CONFIG file before starting the game") do |cfg|
				@options.game_cfg = cfg
			end

			opts.on_tail("-h", "--help", "Display help message") do
				puts opts
				exit
			end

			# Another typical switch to print the version.
			opts.on_tail("-v", "--version", "Print version information") do
				puts Meta::PROG_INFO
				exit
			end

			opts.on_tail("--numeric-version",
						 "Print just the version number") do
				puts Meta::PROG_VERSION
				exit
			end
		end
		opt_parser.parse!(argv)
		@options
	end

	def args_check()
		if @options.game_cfg.empty?
			err_msgn "--game-cfg is undefined"
			return 1
		elsif
			err_no = files_exist_check([@options.game_cfg])
			return (err_no != 0) ? 1 : 0
		end
	end
end
