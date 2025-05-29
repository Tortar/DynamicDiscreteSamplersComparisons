
# DynamicDiscreteSamplersComparisons

Performance Comparison between different implementations of Dynamic Discrete Samplers.

Three different benchmarks are performed with the supported methods:

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

resulting in the figures shown below

![static](https://github.com/user-attachments/assets/c1fe9b65-a84f-457b-9f92-3318495e7f5e)

![dynamic_fixed](https://github.com/user-attachments/assets/e85f3912-fd67-4c51-9b62-74a97d934e3f)

![dynamic_variable](https://github.com/user-attachments/assets/0f42488a-e6dd-4f68-a709-1ab637523add)



The results are stored in csv format in the `data` folder, and as plots in the 
`figures` folder. 

