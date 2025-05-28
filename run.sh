
#!/usr/bin/env bash

sudo apt install cargo

rm -f data/static.csv data/dynamic_fixed.csv data/dynamic_variable.csv

julia compare.jl

cd forest_of_trees
cargo build --release
cargo run --release
cd ..

julia plot.jl
