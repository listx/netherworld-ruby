#!/usr/bin/env ruby
require 'digest/sha1'

require_relative 'random'

seeds = [ :seed_empty\
		, [:seed_manual, (1..255).to_a]\
		, [:seed_manual, (1..256).to_a]\
		, [:seed_manual, (1..257).to_a]\
		, [:seed_manual, (1..258).to_a]\
		, [:seed_manual, (1..259).to_a]\
		, :seed_today
		]

seeds.each do |s|
	# The (*) "splat" operator converts an array into a list of args.
	r = MWC256.new(*s)
	puts r.warmup(100000)
	p r.roll(10)
end
