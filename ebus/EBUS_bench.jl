
using WeightVectors

function initialize_weights_EBUS(rng, WType, N)
	w = WType(N)
	for i in eachindex(w)
		w[i] = abs(randn(rng))
	end
	return w
end

static_samples_EBUS(rng, ds, N) = rand(rng, ds, N)

function dynamic_samples_fixed_dom_EBUS(rng, w, N)
	s = Vector{Int}(undef, N)
	@inbounds for i in 1:N
		s[i] = rand(rng, w)
		w[rand(rng, 1:N)] = abs(randn(rng))
	end
	return s
end

function dynamic_samples_variable_dom_EBUS(rng, w, N)
	s = Vector{Int}(undef, 9*N)
	k = N
	@inbounds for i in 1:9*N
		if N+i > k
			k *= 2
			resize!(w, k)
		end
		s[i] = rand(rng, w)
		w[N+rand(rng, 1:i)] = abs(randn(rng))
	end
	return s
end
