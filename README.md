# DynamicDiscreteSamplersComparison

Performance Comparison between different implementations of Dynamic Discrete Samplers.

Three different benchmarks are performed with the supported methods for each of them:

- static sampling
- dynamic sampling with a fixed domain
- dynamic sampling with a variable domain

To run the benchmarks on Linux, first install the necessary softwares with

```
bash install.sh
```

and then run the benchmarks with

```
bash run.sh
```

The results will be stored in csv format in the `data` folder, and as plots in the 
`figures` folder
