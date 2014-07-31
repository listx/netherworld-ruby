require 'parslet'

require_relative 'config'
require_relative 'effect'
require_relative 'util'

AFFIX_CLASS_NAMES = %w[
	adj
	noun
	noun-proper
	persona
	name
	]

EFFECT_TYPE_NAMES = %w[
	health
	mana
	strength
	wisdom
	attack
	magic-attack
	defense
	magic-defense
	damage
	damage-earth
	damage-fire
	damage-cold
	damage-lightning
	damage-all
	resist-earth
	resist-fire
	resist-cold
	resist-lightning
	resist-all
	lifesteal
	magic-item-find
	gold-earned
	]

class AffixParser < ConfigParser
	rule(:affixes) do
		whitespace_.maybe >>
		affix.as(:affix).repeat(1) >>
		whitespace_.maybe
	end

	rule(:affix) do
		str('affix') >>
		space >>
			AFFIX_CLASS_NAMES.map do |ac|
				whitespace_.maybe >>
				str(ac).as(:class) >>
				space.present? >>
				whitespace_
			end.reduce(:|) >>
		string_literal.as(:name) >>
		whitespace_.maybe >>
		effect.repeat(1).as(:effects)
	end

	rule(:effect) do
		EFFECT_TYPE_NAMES.map do |et|
			str('affix').absent? >>
			str(et).as(:effect_type) >>
			space.present?
		end.reduce(:|) >>
		whitespace_ >>
		number_val.as(:number_val) >>
		whitespace_.maybe
	end

	rule(:number_val) do
		number_val_perc |
		number_val_range.as(:nv_range) |
		integer.as(:nv_constant)
	end

	rule(:number_val_perc) do
		integer.as(:nv_perc) >> str('p') >> whitespace_.maybe
	end

	rule(:number_val_range) do
		integer >> space >> whitespace_.maybe >>
		integer >> whitespace_.maybe
	end

	root(:affixes)
end

def parse_affix_db(pathname)
	str = IO.read(pathname)
	affix_parser = AffixParser.new
	affix_parser.parse(str)
	rescue Parslet::ParseFailed => failure
		puts failure.cause.ascii_tree
end

class AffixParserTransform < Parslet::Transform
	# simple() matches anything but hashes and arrays
	rule(string_literal: simple(:x)) do
		String(x)
	end

	rule(nv_constant: simple(:x)) do
		[:nv_constant, Integer(x)]
	end

	rule(nv_perc: simple(:x)) do
		[:nv_perc, Integer(x)]
	end

	rule(nv_range: simple(:x)) do
		s = String(x).split(' ')
		a = s[0].to_i
		b = s[1].to_i
		[:nv_range, a..b]
	end

	# subtree() matches *everything*
	rule(affix: subtree(:x)) do
		Affix.new(x)
	end
end

class Affix
	attr_accessor :class
	attr_accessor :name
	attr_accessor :effects
#	attr_accessor :hash
	def initialize(hash)
		# We need to use .to_s, because the type is Parslet::Slice
		c = hash[:class].to_s
		@class =
			if AFFIX_CLASS_NAMES.include?(c)
				no_dash(c).to_sym
			else
				raise "unrecognized affix class `#{hash[:class]}'"
			end
		@name = hash[:name]
		@effects = hash[:effects].map do |hash|
			Effect.new(hash)
		end
#		@hash = hash
	end
end
