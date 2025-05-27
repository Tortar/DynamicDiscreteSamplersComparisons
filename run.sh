
#!/usr/bin/env bash

rm -f data/static.csv data/dynamic_fixed.csv data/dynamic_variable.csv

julia compare.jl

julia plot.jl
