#!/usr/bin/env ruby
require 'digest/sha1'

require_relative 'random'

cases = [ :seed_empty\
		, [:seed_manual, (1..255).to_a]\
		, [:seed_manual, (1..256).to_a]\
		, [:seed_manual, (1..257).to_a]\
		, [:seed_manual, (1..258).to_a]\
		, [:seed_manual, (1..259).to_a]\
		, :seed_today
		]

cases.each do |s|
	# The (*) "splat" operator converts an array into a list of args.
	r = MWC256.new(*s)
	puts r.warmup(100000)
end
