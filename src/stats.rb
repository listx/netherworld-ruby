class Stats
	attr_accessor :hash
	def initialize
		# Base stats.
		@hash =\
			{ health: 100\
			, mana: 100\
			, strength: 10\
			, wisdom: 10\
			}
	end
	def merge_exist!(hsh)
		# Check if the given hash only includes keys that already exist.
		hsh.each_key do |k|
			if !@hash.has_key?(k)
				raise "unrecognized hash key"
			end
		end
		@hash.merge!(hsh)
	end
	def add!(sym, n)
		if @hash.has_key?(sym)
			val = @hash[sym]
			@hash.merge!({sym => val + n})
		else
			raise "@hash does not have key #{sym}"
		end
	end
	def sub!(sym, n)
		if @hash.has_key?(sym)
			val = @hash[sym]
			@hash.merge!({sym => val - n})
		else
			raise "@hash does not have key #{sym}"
		end
	end
end
