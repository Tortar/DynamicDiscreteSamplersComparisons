
using Plots, CSV, DataFrames

p = nothing

ts_static = CSV.read("data/static.csv", DataFrame)
ts_dynamic_fixed_dom = CSV.read("data/dynamic_fixed.csv", DataFrame)
ts_dynamic_var_dom = CSV.read("data/dynamic_variable.csv", DataFrame)

Ns = [10^i for i in 3:7]

function plot_vals(Ns, ts, title, ylabel, pname)
    p = nothing
    for (i, k) in enumerate(names(ts))
        if i == 1
            p = plot(Ns, ts[!, k], xscale=:log10, marker=:circle, xticks=Ns, 
                 xlabel="starting sampler size", ylabel=ylabel,
                 title=title, label=k)
        else
            plot!(Ns, ts[!, k], marker=:circle, label=k)
        end
    end
    savefig(p, "figures/" * pname)
end

plot_vals(Ns, ts_static, "Static Distribution", 
    "time per single draw", "static.png")

plot_vals(Ns, ts_dynamic_fixed_dom, "Dynamic Distribution with Fixed Range",
    "time per single update & draw", "dynamic_fixed.png")

plot_vals(Ns, ts_dynamic_var_dom, "Dynamic Distribution with Variable Range", 
    "time per single update & draw", "dynamic_variable.png")
