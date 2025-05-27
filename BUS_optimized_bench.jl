
using DynamicSampling

function initialize_sampler_BUS_opt(rng, N)
	ds = DynamicSampler(rng)
	append!(ds, 1:N, (abs(randn(rng)) for _ in 1:N))
	return ds
end

static_samples_BUS_opt(rng, ds, N) = rand(ds, N)

function dynamic_samples_fixed_dom_BUS_opt(rng, ds, N)
	s = Vector{Int}(undef, N)
	@inbounds for i in 1:N
		s[i] = rand(ds)
		r = rand(rng, 1:N)
		delete!(ds, r)
		push!(ds, r, abs(randn(rng)))
	end
	return s
end

function dynamic_samples_variable_dom_BUS_opt(rng, ds, N)
	s = Vector{Int}(undef, 9*N)
	@inbounds for i in 1:9*N
		s[i] = rand(ds)
		r = N + rand(rng, 1:i)
		(r <= length(ds.weights_assigned)) && (r in ds) && delete!(ds, r)
		push!(ds, r, abs(randn(rng)))
	end
	return s
end

