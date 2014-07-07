def roll(rng, n)
	if (n < 2)
		raise "roll: n must be > 1"
	end
	rng.rand(1..n)
end
