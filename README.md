
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
`figures` folder:

<div style="display: flex; gap: 10px; flex-wrap: wrap;">
  <img src="https://github.com/user-attachments/assets/d394ae94-c9f6-4255-aaaf-8b170afa66bf" alt="static" style="width: 32%;" />
  <img src="https://github.com/user-attachments/assets/adf3c0f5-0a20-49a2-b724-89010bb1eb8b" alt="dynamic_fixed" style="width: 32%;" />
  <img src="https://github.com/user-attachments/assets/258e469c-c606-46a9-9262-8584839be22e" alt="dynamic_variable" style="width: 32%;" />
</div>

<div style="display: flex; gap: 10px; flex-wrap: wrap; margin-top: 10px;">
  <img src="https://github.com/user-attachments/assets/c4461840-a778-4093-9257-51ffded1400b" alt="numerical" style="width: 48%;" />
  <img src="https://github.com/user-attachments/assets/7e8a97ec-820e-40ae-b94b-7610e68050e1" alt="numerical50" style="width: 48%;" />
</div>


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
