
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
colors = Dict("EBUS" => 4, "FT" => 2, "DPA" => 1, "BUS" => 3)

Ns = [10^i for i in 3:7]

function plot_vals(Ns, ts, title, xlabel, ylabel, pname)
    p = nothing
    for (i, k) in enumerate(title != "Performance on Dynamic Sampling with Variable Range" ? ["FT", "DPA", "BUS", "EBUS"] : ["DPA", "BUS", "EBUS"])
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

### numerical

function decaying_weights_sampling_probability(n, t)
    p = BigFloat[]
    for i in 1:n
        push!(p, BigFloat((2.0 + (1/(100*n)) * i))^(1000-t))
    end
    return Float64.(p ./ sum(p))
end

function js_divergence(a, b)
    js = Float64[]
    for (ai, bi) in zip(a, b)
    u = (ai + bi) / 2
    ta = iszero(ai) ? 0.0 : ai * log2(ai) / 2
    tb = iszero(bi) ? 0.0 : bi * log2(bi) / 2
    tu = iszero(u) ? 0.0 : u * log2(u)
    push!(js, ta + tb - tu)
   end
   return sum(js)
end

df_EBUS = CSV.read("data/ebus_numerical.csv", DataFrame, header=false)
M_EBUS = Matrix(df_EBUS)

df_FT = CSV.read("data/forest_of_trees_numerical.csv", DataFrame, header=false)
M_FT = Matrix(df_FT)

df_DPA = CSV.read("data/proposal_array_numerical.csv", DataFrame, header=false)
M_DPA = Matrix(df_DPA)

df_BUS = CSV.read("data/bus_numerical.csv", DataFrame, header=false)
M_BUS = Matrix(df_BUS)

js_EBUS = []
js_FT = []
js_DPA = []
js_BUS = []

for i in 1:100
    p = decaying_weights_sampling_probability(100, i)
    push!(js_EBUS, js_divergence(M_EBUS[i, :], p))
    i <= 51 && push!(js_FT, js_divergence(M_FT[i, :], p))
    i <= 51 && push!(js_DPA, js_divergence(M_DPA[i, :], p))
    i <= 50 && push!(js_BUS, js_divergence(M_BUS[i, :], p))
end

p = plot(js_FT, line = (2.5, :dot), label="FT", 
    title="JS Divergence of Empirical vs. Theoretical Distribution",
    ylabel="divergence", xlabel="decay step", right_margin=10Plots.mm, dpi=1000, legend=:topleft, color = colors["FT"])
plot!(js_DPA, line = (2.5, :dash), label="DPA*", color = colors["DPA"])
plot!(js_BUS, line = (2.5, :dashdot), label="BUS", color = colors["BUS"])
plot!(js_EBUS, line = (2.5, :solid), label="EBUS", color = colors["EBUS"])
savefig(p, "figures/numerical" * ".pdf")
savefig(p, "figures/numerical" * ".png")

k = 1:100
l = @layout [a b; d e]

yticks = [0.01, 0.02, 0.03, 0.04, 0.05, 0.06]
p2 = bar(k, M_EBUS[50, :], bar_width = 0.6, title = "EBUS", legend = false, ylabel="probability", yticks=yticks, ylims=(0, 0.06), linecolor=1,color=1)
p3 = bar(k, M_BUS[50, :], bar_width = 0.6, title = "BUS", legend = false, yticks=yticks, ylims=(0, 0.06), linecolor=1,color=1)
p4 = bar(k, M_FT[50, :], bar_width = 0.6, title = "FT", legend = false, xlabel="index", ylabel="probability", yticks=yticks, ylims=(0, 0.06), linecolor=1,color=1)
p5 = bar(k, M_DPA[50, :], bar_width = 0.6, title = "DPA", legend = false, xlabel="index", yticks=yticks, ylims=(0, 0.06), linecolor=1,color=1)
p = plot(p2, p3, p4, p5, layout = l, 
    plot_title="Empirical Distributions at 50th Decay Step", 
    plot_titlevspan=0.1, dpi=1000, plot_titlefontsize=14)

savefig(p, "figures/numerical50" * ".pdf")
savefig(p, "figures/numerical50" * ".png")
