
using DynamicDiscreteSamplers
using Random, BenchmarkTools, Chairmarks

function initialize_weights!(WType, N)
	w = WType(N)
	for i in eachindex(w)
		w[i] = abs(randn(rng))
	end
	return w
end

static_samples(rng, w, N) = rand(rng, w, N)

function dynamic_samples_fixed_dom(rng, w, N)
	s = Vector{Int}(undef, N)
	@inbounds for i in 1:N
		s[i] = rand(rng, w)
		w[rand(rng, 1:N)] = abs(randn(rng))
	end
	return s
end

function dynamic_samples_variable_dom(rng, w, N)
	s = Vector{Int}(undef, 10*N)
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
