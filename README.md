
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

![static](https://github.com/user-attachments/assets/661dcfcf-8566-45d4-ae13-88bb8f63ca92)
![dynamic_fixed](https://github.com/user-attachments/assets/71d975c5-e742-4874-9ffc-ba70b147be25)
![dynamic_variable](https://github.com/user-attachments/assets/79bedfbd-af86-484a-bfaa-2312b2bf0b06)

The results are stored in csv format in the `data` folder, and as plots in the 
`figures` folder. 

