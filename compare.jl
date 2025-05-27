
using Random, BenchmarkTools, Chairmarks, Plots

include("EBUS_bench.jl")
include("BUS_optimized_bench.jl")
include("ALIAS_TABLE_bench.jl")

rng = Xoshiro(42)

Ns = [10^i for i in 3:8]

ts_static = Dict(
  "EBUS" => Float64[],
  "BUS_opt" => Float64[],
  "ALIAS_TABLE" => Float64[]
)
for N in Ns
	w = initialize_weights_EBUS(rng, FixedSizeWeights, N)
	t_static_EBUS = 10^9 * (@b static_samples_EBUS($rng, $w, $N)).time / N
	push!(ts_static["EBUS"], t_static_EBUS)

    ds = initialize_sampler_BUS_opt(rng, N)
    t_static_BUS_opt = 10^9 * (@b static_samples_BUS_opt($rng, $ds, $N)).time / N
    push!(ts_static["BUS_opt"], t_static_BUS_opt)

    al = initialize_ALIAS_TABLE(rng, N)
    t_static_AL = 10^9 * (@b static_samples_ALIAS_TABLE($rng, $al, $N)).time / N
    push!(ts_static["ALIAS_TABLE"], t_static_AL)
end

ts_dynamic_fixed_dom = Dict(
  "EBUS" => Float64[],
  "BUS_opt" => Float64[]
)
for N in Ns
	w = initialize_weights_EBUS(rng, FixedSizeWeights, N)
	t_dynamic_fixed_dom_EBUS = 10^9 * (@b dynamic_samples_fixed_dom_EBUS($rng, $w, $N)).time / N
	push!(ts_dynamic_fixed_dom["EBUS"], t_dynamic_fixed_dom_EBUS)

    ds = initialize_sampler_BUS_opt(rng, N)
    t_dynamic_fixed_dom_BUS_opt = 10^9 * (@b dynamic_samples_fixed_dom_BUS_opt($rng, $ds, $N)).time / N
    push!(ts_dynamic_fixed_dom["BUS_opt"], t_dynamic_fixed_dom_BUS_opt)
end

ts_dynamic_var_dom = Dict(
  "EBUS" => Float64[],
  "BUS_opt" => Float64[]
)
for N in Ns
	t_dynamic_var_dom_EBUS = @b initialize_weights_EBUS(rng, ResizableWeights, N) dynamic_samples_variable_dom_EBUS($rng, _, $N) evals=1
	t_dynamic_var_dom_EBUS = t_dynamic_var_dom_EBUS.time
	t_dynamic_var_dom_EBUS *= 10^9 / (9*N)
	push!(ts_dynamic_var_dom["EBUS"], t_dynamic_var_dom_EBUS)

    t_dynamic_var_dom_BUS_opt = @b initialize_sampler_BUS_opt(rng, N) dynamic_samples_variable_dom_BUS_opt($rng, _, $N) evals=1
    t_dynamic_var_dom_BUS_opt = t_dynamic_var_dom_BUS_opt.time
    t_dynamic_var_dom_BUS_opt *= 10^9 / (9*N)
    push!(ts_dynamic_var_dom["BUS_opt"], t_dynamic_var_dom_BUS_opt)
end

p = nothing

for (i, k) in enumerate(keys(ts_static))
    if i == 1
        p = plot(Ns, ts_static[k], xscale=:log10, marker=:circle, xticks=Ns, 
      	     xlabel="starting sampler size", ylabel="time per single draw",
      	     title="Static Distribution", label=k)
    else
        plot!(Ns, ts_static[k], marker=:circle, label=k)
    end
end
display(p)

for (i, k) in enumerate(keys(ts_dynamic_fixed_dom))
    if i == 1
        p = plot(Ns, ts_dynamic_fixed_dom[k], xscale=:log10, marker=:circle, xticks=Ns, 
      	     xlabel="starting sampler size", ylabel="time per single update & draw",
      	     title="Dynamic Distribution with Fixed Range", label=k)
    else
        plot!(Ns, ts_dynamic_fixed_dom[k], marker=:circle, label=k)
    end
end
display(p)

for (i, k) in enumerate(keys(ts_dynamic_var_dom))
    if i == 1
        p = plot(Ns, ts_dynamic_var_dom[k], xscale=:log10, marker=:circle, xticks=Ns, 
      	     xlabel="starting sampler size", ylabel="time per single update & draw",
      	     title="Dynamic Distribution with Variable Range", label=k)
    else
        plot!(Ns, ts_dynamic_var_dom[k], marker=:circle, label=k)
    end
end
display(p)