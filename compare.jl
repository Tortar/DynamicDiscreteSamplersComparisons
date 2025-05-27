
using Plots

include("EBUS.jl")
include("BUS_optimized.jl")

rng = Xoshiro(42)

Ns = [10^i for i in 3:7]

ts_static = Dict(
  :EBUS => Float64[],
  :BUS_optimized => Float64[]
)

for N in Ns
	w = initialize_weights!(FixedSizeWeights, N)
	t_static = 10^9 * (@b static_samples($rng, $w, $N)).time / N
	push!(ts_static[:EBUS], t_static)
end

ts_dynamic_fixed_dom = Dict(
  :EBUS => Float64[],
  :BUS_optimized => Float64[]
)
for N in Ns
	w = initialize_weights!(FixedSizeWeights, N)
	t_dynamic_fixed_dom = 10^9 * (@b dynamic_samples_fixed_dom($rng, $w, $N)).time / N
	push!(ts_dynamic_fixed_dom[:EBUS], t_dynamic_fixed_dom)
end

ts_dynamic_var_dom = Dict(
  :EBUS => Float64[],
  :BUS_optimized => Float64[]
)
for N in Ns
	w = initialize_weights!(ResizableWeights, N)
	t_dynamic_var_dom = @b initialize_weights!(ResizableWeights, N) dynamic_samples_variable_dom($rng, _, $N) evals=1
	t_dynamic_var_dom = t_dynamic_var_dom.time
	t_dynamic_var_dom *= 10^9
	t_dynamic_var_dom /= 9*N
	push!(ts_dynamic_var_dom[:EBUS], t_dynamic_var_dom)
end

for (i, k) in enumerate(keys(ts_static))
    if i == 1
        plot(Ns, ts_static[k], xscale=:log10, marker=:circle, xticks=Ns, 
      	     xlabel="starting sampler size", ylabel="time per single draw",
      	     label="Static Distribution", label=k)
    else
        plot!(Ns, ts_static[k], marker=:circle)
    end
end

for (i, k) in enumerate(keys(ts_static))
    if i == 1
        plot(Ns, ts_dynamic_fixed_dom[k], xscale=:log10, marker=:circle, xticks=Ns, 
      	     xlabel="starting sampler size", ylabel="time per single update & draw",
      	     title="Dynamic Distribution with Fixed Range", label=k)
    else
        plot!(Ns, ts_dynamic_fixed_dom[k], marker=:circle)
    end
end

for (i, k) in enumerate(keys(ts_static))
    if i == 1
        plot(Ns, ts_dynamic_var_dom[k], xscale=:log10, marker=:circle, xticks=Ns, 
      	     xlabel="starting sampler size", ylabel="time per single update & draw",
      	     title="Dynamic Distribution with Variable Range", label=k)
    else
        plot!(Ns, ts_dynamic_var_dom[k], marker=:circle)
    end
end
