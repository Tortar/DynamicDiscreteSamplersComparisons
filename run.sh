
#!/usr/bin/env bash

mkdir -p data

rm -f data/static.csv data/dynamic_fixed.csv data/dynamic_variable.csv

julia compare.jl

cd forest_of_trees
cargo build --release
cargo run --release
cd ..

cd proposal_array
rm -r build
mkdir build && cd build    # out-of-source build
cmake .. -DCMAKE_BUILD_TYPE=Release
cmake --build .               # or: make -j$(nproc)
./bench_sampling              # run the generated executable
cd ..
cd ..

mkdir -p figures

julia plot.jl
