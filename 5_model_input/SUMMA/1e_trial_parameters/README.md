# Trial parameters
SUMMA uses a hierarchical approach to reading parameter values from various files. Initially, all model parameters are set to values found in the `basinParamInfo.txt` and `localParamInfo.txt` files. This leads to spatially constant parameter values across the modeling domain: all HRUs have identical parameter values after this step. Next, SUMMA finds more appropriate parameter values for each HRU for certain soil and vegetation properties from look-up tables. This step required the `*.TBL` files (base settings) and the `soilTypeIndex` and `vegTypeIndex` values found in the attributes `.nc` file. At the end of this step, some parameters are still spatially uniform, while certain vegetation and soil parameters now have look-up table values and therefore vary between HRUs (provided that the HRUs actually have different vegetation and/or soil types). Finally, any parameter can once more be overwritten with a new value if defined in the trial parameter `.nc` file. 

This script creates a trial parameter file according to instructions provided in the control file. Control file variable `settings_summa_trialParam_n` specifies how many trial parameter values are specified in the current control file. The following lines in the control file can contain variables `settings_summa_trialParam_1`, `settings_summa_trialParam_2`, etc., each of which is followed by a string of `[SUMMA parameter],[value]`. The code includes any specified `[SUMMA parameter]` in the trial parameter file and assigns it `[value]`. By default, `[value]` is stored as a(n array of) float(s). As an example, the Bow at Banff control file includes the lines:

```
settings_summa_trialParam_n | 1          
settings_summa_trialParam_1 | maxstep,900
```
which results in a trial parameter file that specifies SUMMA parameter `maxstep` (the maximum length of any model step as `900` (seconds). While the ERA5 forcing is provided at hourly resolution, this forces SUMMA to take at least 4 sub-steps per model time step. This setting can be used to control the numerical accuracy of the solution. 

The trial parameter file can also be used to easily connect SUMMA to a calibration algorithm. See: https://summa.readthedocs.io/en/latest/input_output/SUMMA_input/#infile_trial_parameters