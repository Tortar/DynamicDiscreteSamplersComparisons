
using Random, BenchmarkTools, Chairmarks, CSV, DataFrames, Statistics

include("ebus/EBUS_bench.jl")
include("bus_opt/BUS_optimized_bench.jl")
include("alias_table/ALIAS_TABLE_bench.jl")

median_time(b) = median([x.time for x in b.samples])

rng = Xoshiro(42)

Ns = [10^i for i in 3:5]

ts_static = Dict(
  "EBUS" => Float64[],
  "BUS_opt" => Float64[],
  "ALIAS_TABLE" => Float64[]
)
for N in Ns
	w = initialize_weights_EBUS(rng, FixedSizeWeights, N)
	t_static_EBUS = 10^9 * median_time(@be static_samples_EBUS($rng, $w, $N)) / N
	push!(ts_static["EBUS"], t_static_EBUS)

    ds = initialize_sampler_BUS_opt(rng, N)
    t_static_BUS_opt = 10^9 * median_time(@be static_samples_BUS_opt($rng, $ds, $N)) / N
    push!(ts_static["BUS_opt"], t_static_BUS_opt)

    al = initialize_ALIAS_TABLE(rng, N)
    t_static_AL = 10^9 * median_time(@be static_samples_ALIAS_TABLE($rng, $al, $N)) / N
    push!(ts_static["ALIAS_TABLE"], t_static_AL)
end
df = DataFrame(ts_static)
file = "data/static.csv"
CSV.write(file, df; append = isfile(file), writeheader = true)

ts_dynamic_fixed_dom = Dict(
  "EBUS" => Float64[],
  "BUS_opt" => Float64[]
)
for N in Ns
	w = initialize_weights_EBUS(rng, FixedSizeWeights, N)
	t_dynamic_fixed_dom_EBUS = 10^9 * median_time(@be dynamic_samples_fixed_dom_EBUS($rng, $w, $N)) / N
	push!(ts_dynamic_fixed_dom["EBUS"], t_dynamic_fixed_dom_EBUS)

    ds = initialize_sampler_BUS_opt(rng, N)
    t_dynamic_fixed_dom_BUS_opt = 10^9 * median_time(@be dynamic_samples_fixed_dom_BUS_opt($rng, $ds, $N)) / N
    push!(ts_dynamic_fixed_dom["BUS_opt"], t_dynamic_fixed_dom_BUS_opt)
end
df = DataFrame(ts_dynamic_fixed_dom)
file = "data/dynamic_fixed.csv"
CSV.write(file, df; append = isfile(file), writeheader = true)

ts_dynamic_var_dom = Dict(
  "EBUS" => Float64[],
  "BUS_opt" => Float64[]
)
for N in Ns
	t_dynamic_var_dom_EBUS = @be initialize_weights_EBUS(rng, ResizableWeights, N) dynamic_samples_variable_dom_EBUS($rng, _, $N) evals=1
	t_dynamic_var_dom_EBUS = median_time(t_dynamic_var_dom_EBUS)
	t_dynamic_var_dom_EBUS *= 10^9 / (9*N)
	push!(ts_dynamic_var_dom["EBUS"], t_dynamic_var_dom_EBUS)

    t_dynamic_var_dom_BUS_opt = @be initialize_sampler_BUS_opt(rng, N) dynamic_samples_variable_dom_BUS_opt($rng, _, $N) evals=1
    t_dynamic_var_dom_BUS_opt = median_time(t_dynamic_var_dom_BUS_opt)
    t_dynamic_var_dom_BUS_opt *= 10^9 / (9*N)
    push!(ts_dynamic_var_dom["BUS_opt"], t_dynamic_var_dom_BUS_opt)
end
df = DataFrame(ts_dynamic_var_dom)
file = "data/dynamic_variable.csv"
CSV.write(file, df; append = isfile(file), writeheader = true)
