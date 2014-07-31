require 'parslet'

require_relative 'effect'
require_relative 'util'

class Effect
	attr_accessor :type
	attr_accessor :number_val
	def initialize(hash)
		et = hash[:effect_type].to_s
		@type =
			if EFFECT_TYPE_NAMES.include?(et)
				no_dash(et).to_sym
			else
				raise "unrecognized effect type `#{hash[:effect_type]}'"
			end
		@number_val = hash[:number_val]
	end
end
