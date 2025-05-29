
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

<table width="100%">
  <tr>
    <td width="33.3%" align="center">
      <img
        src="https://github.com/user-attachments/assets/7b944835-2635-4548-89e2-fae9fd9a2da5"
        alt="static"
        width="100%"
        style="height: auto;"
      >
    </td>
    <td width="33.3%" align="center">
      <img
        src="https://github.com/user-attachments/assets/0d59eda3-975f-4efa-8ce8-f476ca10f8de"
        alt="dynamic_fixed"
        width="100%"
        style="height: auto;"
      >
    </td>
    <td width="33.3%" align="center">
      <img
        src="https://github.com/user-attachments/assets/823d5354-304f-460b-9c99-9e5b860adbed"
        alt="dynamic_variable"
        width="100%"
        style="height: auto;"
      >
    </td>
  </tr>
</table>




The results are stored in csv format in the `data` folder, and as plots in the 
`figures` folder. 

