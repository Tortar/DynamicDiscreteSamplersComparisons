
# DynamicDiscreteSamplersComparisons

Performance Comparison between different implementations of Dynamic Discrete Samplers.

Currently, it compares four algorithms:

- EBUS (https://github.com/LilithHafner/WeightVectors.jl)
- BUS (https://github.com/CUHK-DBGroup/WSS-WIRS)
- FT (https://github.com/manpen/dynamic-weighted-index)
- DPA* (https://github.com/Daniel-Allendorf/proposal-array)

Three different benchmarks are performed:

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

The results are stored in csv format in the `data` folder, and as plots in the 
`figures` folder. 


## Citation

If you use this package in a publication, or simply want to refer to it, please cite the paper below:

```
@misc{hafner2025exactsampler,
      title={An Exact and Efficient Sampler for Dynamic Discrete Distributions}, 
      author={Lilith Orion Hafner and Adriano Meligrana},
      year={2025},
      eprint={2506.14062},
      archivePrefix={arXiv},
      primaryClass={cs.DS},
      url={https://arxiv.org/abs/2506.14062}, 
}
```
