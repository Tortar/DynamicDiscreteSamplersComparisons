
using Plots, CSV, DataFrames

p = nothing

ts_static = CSV.read("data/static.csv", DataFrame)
ts_dynamic_fixed_dom = CSV.read("data/dynamic_fixed.csv", DataFrame)
ts_dynamic_var_dom = CSV.read("data/dynamic_variable.csv", DataFrame)

ts_static = select(ts_static, [:EBUS, :BUS, :FOREST_OF_TREES, :PROPOSAL_ARRAY])
rename_map = Dict(:EBUS => :EBUS, :FOREST_OF_TREES => :FT, :PROPOSAL_ARRAY => :DPA, :BUS => :BUS)
rename!(ts_static, rename_map)

ts_dynamic_fixed_dom = select(ts_dynamic_fixed_dom, [:EBUS, :BUS, :FOREST_OF_TREES, :PROPOSAL_ARRAY])
rename_map = Dict(:EBUS => :EBUS, :FOREST_OF_TREES => :FT, :PROPOSAL_ARRAY => :DPA, :BUS => :BUS)
rename!(ts_dynamic_fixed_dom, rename_map)

ts_dynamic_var_dom = select(ts_dynamic_var_dom, [:EBUS, :BUS, :PROPOSAL_ARRAY])
rename_map = Dict(:EBUS => :EBUS, :PROPOSAL_ARRAY => :DPA, :BUS => :BUS)
rename!(ts_dynamic_var_dom, rename_map)

markers = Dict("EBUS" => :circle, "FT" => :rect, "DPA" => :utriangle, "BUS" => :xcross)
colors = Dict("EBUS" => 1, "FT" => 2, "DPA" => 3, "BUS" => 4)

Ns = [10^i for i in 3:7]

function plot_vals(Ns, ts, title, xlabel, ylabel, pname)
    p = nothing
    for (i, k) in enumerate(names(ts))
        if i == 1
            p = plot(Ns, ts[!, k], xscale=:log10, marker=markers[k], xticks=Ns, 
                 xlabel=xlabel, ylabel=ylabel, markersize=6, line = (2, :dash),
                 title=title, label=(k == "DPA" ? (string(k) * "*") : (k == "BUS_jl" ? "BUS-OPT" : string(k))),
                 ylims=(0, Inf), widen = true, legend=:topleft, right_margin=10Plots.mm, color = colors[k], dpi=1000)
        else
            plot!(Ns, ts[!, k], marker=markers[k], label=(k == "DPA" ? (string(k) * "*") : (k == "BUS_jl" ? "BUS-OPT" : string(k))),
                ylims=(0, Inf), widen = true, color = colors[k], markersize=6, line = (2, :dash), dpi=1000)
        end
    end
    savefig(p, "figures/" * pname * ".pdf")
    savefig(p, "figures/" * pname * ".png")
end

plot_vals(Ns, ts_static, "Performance on Static Sampling", "sampler size",
    "time per single draw (ns)", "static")

plot_vals(Ns, ts_dynamic_fixed_dom, "Performance on Dynamic Sampling with Fixed Range", "sampler size",
    "time per single update & draw (ns)", "dynamic_fixed")

plot_vals(Ns, ts_dynamic_var_dom, "Performance on Dynamic Sampling with Variable Range", "starting sampler size",
    "time per single update & draw (ns)", "dynamic_variable")
