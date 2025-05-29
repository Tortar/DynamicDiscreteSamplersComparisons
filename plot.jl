
using Plots, CSV, DataFrames

p = nothing

ts_static = CSV.read("data/static.csv", DataFrame)
ts_dynamic_fixed_dom = CSV.read("data/dynamic_fixed.csv", DataFrame)
ts_dynamic_var_dom = CSV.read("data/dynamic_variable.csv", DataFrame)

ts_static = select(ts_static, [:EBUS, :FOREST_OF_TREES, :PROPOSAL_ARRAY])
rename_map = Dict(:EBUS => :EBUS, :FOREST_OF_TREES => :FT, :PROPOSAL_ARRAY => :DPA)
rename!(ts_static, rename_map)

ts_dynamic_fixed_dom = select(ts_dynamic_fixed_dom, [:EBUS, :FOREST_OF_TREES, :PROPOSAL_ARRAY])
rename_map = Dict(:EBUS => :EBUS, :FOREST_OF_TREES => :FT, :PROPOSAL_ARRAY => :DPA)
rename!(ts_dynamic_fixed_dom, rename_map)

ts_dynamic_var_dom = select(ts_dynamic_var_dom, [:EBUS, :PROPOSAL_ARRAY])
rename_map = Dict(:EBUS => :EBUS, :PROPOSAL_ARRAY => :DPA)
rename!(ts_dynamic_var_dom, rename_map)

Ns = [10^i for i in 3:7]

function plot_vals(Ns, ts, title, ylabel, pname)
    p = nothing
    for (i, k) in enumerate(names(ts))
        if i == 1
            p = plot(Ns, ts[!, k], xscale=:log10, marker=:circle, xticks=Ns, 
                 xlabel="starting sampler size", ylabel=ylabel,
                 title=title, label=(k == "DPA" ? (string(k) * "*") : string(k)),
                 ylims=(0, Inf), widen = true)
        else
            plot!(Ns, ts[!, k], marker=:circle, label=(k == "DPA" ? (string(k) * "*") : string(k)),
                ylims=(0, Inf), widen = true)
        end
    end
    savefig(p, "figures/" * pname * ".pdf")
    savefig(p, "figures/" * pname * ".png")
end

plot_vals(Ns, ts_static, "Static Distribution", 
    "time per single draw (ns)", "static")

plot_vals(Ns, ts_dynamic_fixed_dom, "Dynamic Distribution with Fixed Range",
    "time per single update & draw (ns)", "dynamic_fixed")

plot_vals(Ns, ts_dynamic_var_dom, "Dynamic Distribution with Variable Range", 
    "time per single update & draw (ns)", "dynamic_variable")
