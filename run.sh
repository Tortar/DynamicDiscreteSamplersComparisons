
#!/usr/bin/env bash

rm -f static.csv dynamic_fixed.csv dynamic_variable.csv

julia compare.jl

julia plot.jl
