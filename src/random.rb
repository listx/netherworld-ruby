require 'date'
require 'digest/sha1'

require_relative 'util'

U8_MAX = 255
U32_MAX = 4294967295
U64_MAX = 18446744073709551615
U8_MOD = U8_MAX + 1
U32_MOD = U32_MAX + 1
U64_MOD = U64_MAX + 1

# Code adapted from by https://hackage.haskell.org/package/mwc-random by Bryan
# O'Sullivan and https://github.com/eli-frey/mwc-rng by Vincent Elisha Lee Frey.
class MWC256
	attr_accessor :state
	@ioff
	@coff
	@aa
	@state
	DEFAULT_SEED_ARRAY = [
		0x7042e8b3, 0x06f7f4c5, 0x789ea382, 0x6fb15ad8, 0x54f7a879, 0x0474b184,
		0xb3f8f692, 0x4114ea35, 0xb6af0230, 0xebb457d2, 0x47693630, 0x15bc0433,
		0x2e1e5b18, 0xbe91129c, 0xcc0815a0, 0xb1260436, 0xd6f605b1, 0xeaadd777,
		0x8f59f791, 0xe7149ed9, 0x72d49dd5, 0xd68d9ded, 0xe2a13153, 0x67648eab,
		0x48d6a1a1, 0xa69ab6d7, 0x236f34ec, 0x4e717a21, 0x9d07553d, 0x6683a701,
		0x19004315, 0x7b6429c5, 0x84964f99, 0x982eb292, 0x3a8be83e, 0xc1df1845,
		0x3cf7b527, 0xb66a7d3f, 0xf93f6838, 0x736b1c85, 0x5f0825c1, 0x37e9904b,
		0x724cd7b3, 0xfdcb7a46, 0xfdd39f52, 0x715506d5, 0xbd1b6637, 0xadabc0c0,
		0x219037fc, 0x9d71b317, 0x3bec717b, 0xd4501d20, 0xd95ea1c9, 0xbe717202,
		0xa254bd61, 0xd78a6c5b, 0x043a5b16, 0x0f447a25, 0xf4862a00, 0x48a48b75,
		0x1e580143, 0xd5b6a11b, 0x6fb5b0a4, 0x5aaf27f9, 0x668bcd0e, 0x3fdf18fd,
		0x8fdcec4a, 0x5255ce87, 0xa1b24dbf, 0x3ee4c2e1, 0x9087eea2, 0xa4131b26,
		0x694531a5, 0xa143d867, 0xd9f77c03, 0xf0085918, 0x1e85071c, 0x164d1aba,
		0xe61abab5, 0xb8b0c124, 0x84899697, 0xea022359, 0x0cc7fa0c, 0xd6499adf,
		0x746da638, 0xd9e5d200, 0xefb3360b, 0x9426716a, 0xabddf8c2, 0xdd1ed9e4,
		0x17e1d567, 0xa9a65000, 0x2f37dbc5, 0x9a4b8fd5, 0xaeb22492, 0x0ebe8845,
		0xd89dd090, 0xcfbb88c6, 0xb1325561, 0x6d811d90, 0x03aa86f4, 0xbddba397,
		0x0986b9ed, 0x6f4cfc69, 0xc02b43bc, 0xee916274, 0xde7d9659, 0x7d3afd93,
		0xf52a7095, 0xf21a009c, 0xfd3f795e, 0x98cef25b, 0x6cb3af61, 0x6fa0e310,
		0x0196d036, 0xbc198bca, 0x15b0412d, 0xde454349, 0x5719472b, 0x8244ebce,
		0xee61afc6, 0xa60c9cb5, 0x1f4d1fd0, 0xe4fb3059, 0xab9ec0f9, 0x8d8b0255,
		0x4e7430bf, 0x3a22aa6b, 0x27de22d3, 0x60c4b6e6, 0x0cf61eb3, 0x469a87df,
		0xa4da1388, 0xf650f6aa, 0x3db87d68, 0xcdb6964c, 0xb2649b6c, 0x6a880fa9,
		0x1b0c845b, 0xe0af2f28, 0xfc1d5da9, 0xf64878a6, 0x667ca525, 0x2114b1ce,
		0x2d119ae3, 0x8d29d3bf, 0x1a1b4922, 0x3132980e, 0xd59e4385, 0x4dbd49b8,
		0x2de0bb05, 0xd6c96598, 0xb4c527c3, 0xb5562afc, 0x61eeb602, 0x05aa192a,
		0x7d127e77, 0xc719222d, 0xde7cf8db, 0x2de439b8, 0x250b5f1a, 0xd7b21053,
		0xef6c14a1, 0x2041f80f, 0xc287332e, 0xbb1dbfd3, 0x783bb979, 0x9a2e6327,
		0x6eb03027, 0x0225fa2f, 0xa319bc89, 0x864112d4, 0xfe990445, 0xe5e2e07c,
		0xf7c6acb8, 0x1bc92142, 0x12e9b40e, 0x2979282d, 0x05278e70, 0xe160ba4c,
		0xc1de0909, 0x458b9bf4, 0xbfce9c94, 0xa276f72a, 0x8441597d, 0x67adc2da,
		0x6162b854, 0x7f9b2f4a, 0x0d995b6b, 0x193b643d, 0x399362b3, 0x8b653a4b,
		0x1028d2db, 0x2b3df842, 0x6eecafaf, 0x261667e9, 0x9c7e8cda, 0x46063eab,
		0x7ce7a3a1, 0xadc899c9, 0x017291c4, 0x528d1a93, 0x9a1ee498, 0xbb7d4d43,
		0x7837f0ed, 0x34a230cc, 0x614a628d, 0xb03f93b8, 0xd72e3b08, 0x604c98db,
		0x3cfacb79, 0x8b81646a, 0xc0f082fa, 0xd1f92388, 0xe5a91e39, 0xf95c756d,
		0x1177742f, 0xf8819323, 0x5c060b80, 0x96c1cd8f, 0x47d7b440, 0xbbb84197,
		0x35f749cc, 0x95b0e132, 0x8d90ad54, 0x5c3f9423, 0x4994005b, 0xb58f53b9,
		0x32df7348, 0x60f61c29, 0x9eae2f32, 0x85a3d398, 0x3b995dd4, 0x94c5e460,
		0x8e54b9f3, 0x87bc6e2a, 0x90bbf1ea, 0x55d44719, 0x2cbbfe6e, 0x439d82f0,
		0x4eb3782d, 0xc3f1e669, 0x61ff8d9e, 0x0909238d, 0xef406165, 0x09c1d762,
		0x705d184f, 0x188f2cc4, 0x9c5aa12a, 0xc7a5d70e, 0xbc78cb1b, 0x1d26ae62,
		0x23f96ae3, 0xd456bf32, 0xe4654f55, 0x31462bd8 ]

	# Depending on the seed type, we seed the RNG differently.
	def initialize(seed_type, seed = [])
		case seed_type
		when :seed_empty
			init_state(seed)
		# Behaves the same way as `initialize` from mwc-random library.
		when :seed_mwc
			ws = seed.take(256)
			ic = seed.drop(256)
			if seed.size == 258
				init_state(seed)
			else
				init_state(ws)
			end
		# Like :seed_mwc, but performs extra SHA/XOR mixing to the seed's first
		# 256 values (i.e., the index 'i' and multiplicand/consant 'c' values
		# are not mixed).
		when :seed_manual
			ws = seed.take(256)
			i = seed[256]
			c = seed[257]
			if ws.include?(0) || c == 0
				raise "one or more values in `ws` or `c` is 0"
			elsif ws.size != ws.uniq.size
				raise "some values in `ws` are the same"
			else
				if seed.size == 258
					init_state(sha1_xor(ws) + [i, c])
				else
					init_state(sha1_xor(ws))
				end
			end
		when :seed_today
			t = Time.new.utc
			d = Date.new(t.year, t.month, t.day)
			init_state(sha1_xor([d.mjd]))
		else
			raise "unrecognized seed_type `#{seed_type}'"
		end
	end

	def sha1_xor(ws)
		ws_ary = []
		ws.each do |w|
			acc = ""
			ws_ary << sha1_inflate(octets_le(w).pack('C*'))
		end
		ws_ary.transpose.map {|w32s| w32s.reduce(:^)}
	end

	# This method is always called on intialization; it is the internal numeric
	# way we initialize the RNG. The input seed is a list of unsigned 32-bit
	# numbers. The first 256 values are called `ws`, after "Word32"s. The 257th
	# value is the index, or `i`. The 258th value is the mutable constant, `c`.
	def init_state(seed)
		@ioff = 256
		@coff = 257
		@aa = 1540315826
		state = []

		for i in 0..255
			if i >= seed.size
				if seed.empty?
					state[i] = DEFAULT_SEED_ARRAY[i]
				else
					state[i] = DEFAULT_SEED_ARRAY[i] ^ seed[i % seed.size]
				end
			else
				state[i] = seed[i]
			end
		end

		if seed.size == 258
			state[@ioff] = seed[@ioff] & U8_MAX
			state[@coff] = seed[@coff]
		else
			state[@ioff] = 255
			state[@coff] = 362436
		end

		@state = state
	end

	# Because Ruby does not have fixed-size types of 32 and 64 bits, we have to
	# emulate them with liberal use of the modulo `%` operator.
	#
	# The actual PRNG algorithm here is from Feb 25, 2003
	# (https://groups.google.com/d/msg/sci.math/k3kVM8KwR-s/jxPdZl8XWZkJ), by
	# George Marsaglia, from the topic "RNGs" on the sci.math newsgroup. Another
	# (simpler) version, posted on May 13, 2003
	# (https://groups.google.com/forum/#!msg/comp.lang.c/qZFQgKRCQGg/rmPkaRHqxOMJ),
	# also by Marsaglia from the topic "good C random number generator" on the
	# comp.lang.c newsgroup, is known to exist. We use the first version because
	# that is what Bryan O'Sullivan's `mwc-random` uses (which is what
	# NetherWorld uses).
	def rand64()
		i = (@state[@ioff] + 1) % 256
		j = (i + 1) % 256
		c = @state[@coff]
		sti = @state[i]
		stj = @state[j]
		t = (@aa * sti + c) % U64_MOD
		c = t >> 32
		x = (t + c) % U32_MOD
		if (x < c)
			(x += 1) % U32_MOD
			(c += 1) % U32_MOD
		end
		u = (@aa * stj + c) % U64_MOD
		d = u >> 32
		y = (u + d) % U32_MOD
		if (y < d)
			(y += 1) % U32_MOD
			(d += 1) % U32_MOD
		end
		@state[i] = x
		@state[j] = y
		@state[@ioff] = j
		@state[@coff] = d

		x << 32 | (y % U64_MOD)
	end

	def uniform_range(a, b)
		i = nil
		j = nil
		if a < b
			i, j = a, b
		else
			i, j = b, a
		end

		n = 1 + (j - i)
		max_bound = U64_MAX
		buckets = max_bound / n
		max_n = buckets * n
		while true do
			x = rand64()
			if x < max_n
				break
			end
		end
		return (i + (x / buckets)) % U64_MOD
	end

	def warmup(n)
		if n < 1
			raise "n must be at least 1"
		else
			for i in 1..n
				n = rand64
			end
		end
		n
	end

	# Simulate an n-sided die, by randomly choosing a number from the interval
	# [1, n]. If n is 2, it is like a coin flip.
	def roll(n)
		if (n < 2)
			raise "roll: n must be > 1"
		end
		uniform_range(1, n)
	end

	# Choose `count` elements from `xs`.
	def rnd_sample(count, xs)
		if count == 0 || xs.empty?
			[]
		elsif count < 0
			raise "rnd_sample: count must be > 0"
		else
			idx = uniform_range(0, xs.size - 1)
			chosen = xs.delete_at(idx)
			rest = rnd_sample(count - 1, xs)
			[chosen] + rest
		end
	end
end

# Returns an array of Word32s.
def sha1_inflate(bytestring)
	w32s = []
	hash = ""
	while hash.size < (256 * 4) do
		bytestring = Digest::SHA1.digest bytestring
		hash += bytestring
	end
	to_w32s(hash[0..((256 * 4) - 1)])
end

# Convert a hex string into Word32s.
def to_w32s(hex_string)
	# might need to reverse the chars (e.g., 'abcd' into 'dcba') if
	# endianness matters...
	hex_string.split(//).each_slice(2).to_a.map do |nibbles|
		nibbles.join
	end.join.unpack('V*').flatten
end

# Little-endian octets. I.e., grab the 4 octets inside a 32-bit word.
def octets_le(w)
	[w, w >> 8, w >> 16, w >> 24].map {|x| x & U8_MAX}
end
