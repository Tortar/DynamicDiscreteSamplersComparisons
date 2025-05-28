
curl -fsSL https://install.julialang.org | sh

julia --project=. -e 'using Pkg; Pkg.instantiate()'

julia --project=. -e 'using Pkg; Pkg.develop(url="https://github.com/LilithHafner/DynamicDiscreteSamplers.jl.git")'

sudo apt install cargo

sudo apt install cmake