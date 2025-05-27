
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

rng = Xoshiro(42)

Ns = [10^i for i in 3:7]
ts_static = []
for N in Ns
	w = initialize_weights!(FixedSizeWeights, N)
	t_static = 10^9 * (@b static_samples($rng, $w, $N)).time / N
	push!(ts_static, t_static)
end

ts_dynamic_fixed_dom = []
for N in Ns
	w = initialize_weights!(FixedSizeWeights, N)
	t_dynamic_fixed_dom = 10^9 * (@b dynamic_samples_fixed_dom($rng, $w, $N)).time / N
	push!(ts_dynamic_fixed_dom, t_dynamic_fixed_dom)
end

ts_dynamic_var_dom = []
for N in Ns
	w = initialize_weights!(ResizableWeights, N)
	t_dynamic_var_dom = @b initialize_weights!(ResizableWeights, N) dynamic_samples_variable_dom($rng, _, $N) evals=1
	t_dynamic_var_dom = t_dynamic_var_dom.time
	t_dynamic_var_dom *= 10^9
	t_dynamic_var_dom /= 9*N
	push!(ts_dynamic_var_dom, t_dynamic_var_dom)
end

using Plots

plot(Ns, ts_static, xscale=:log10, marker=:circle, xticks=Ns, 
	 xlabel="starting sampler size", ylabel="time per single draw",
	 label="Static Distribution")

plot!(Ns, ts_dynamic_fixed_dom, xscale=:log10, marker=:circle, xticks=Ns,
	 xlabel="starting sampler size", ylabel="time per single update & draw",
	 label="Dynamic Distribution with Fixed Range")

plot!(Ns, ts_dynamic_var_dom, xscale=:log10, marker=:circle, xticks=Ns,
	 xlabel="starting sampler size", ylabel="time per single update & draw", 
	 label="Dynamic Distribution with Variable Range")
