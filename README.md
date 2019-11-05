# OPFSampler

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://invenia.github.io/OPFSampler.jl/stable)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://invenia.github.io/OPFSampler.jl/dev)
[![Build Status](https://travis-ci.com/invenia/OPFSampler.jl.svg?branch=master)](https://travis-ci.com/invenia/OPFSampler.jl)
[![Build Status](https://ci.appveyor.com/api/projects/status/github/invenia/OPFSampler.jl?svg=true)](https://ci.appveyor.com/project/invenia/OPFSampler-jl)
[![Codecov](https://codecov.io/gh/invenia/OPFSampler.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/invenia/OPFSampler.jl)

# Goal
The goal of this package is to provide functions that take a power grid as input, vary its parameters and generate feasible DC and AC-OPF samples along with the OPF solution. This helps the user to explore a variety of distinct active sets of constraints for the synthetic cases and mimic the time-varying behaviour of the OPF input parameters.

## Sampler
`RunDCSampler()` and `RunACSampler()` are the two main functions in this section that trigger the sampler to generate DC and AC-OPF samples, respectively.

## DC Sampler
The DC sampler gives you the functionality to vary the grid parameters by rescaling them using factors drawn from uniform distribution of the form $\mathcal{U}(1-\delta, 1+\delta)$. The user is able to re-scale the following parameters:

* nodal load active power,
* maximum active power output of generators,
* line thermal ratings,
* line reactance values.

#### Minimal Working Example in Julia
Setting up the path and activating the package:
```
cd("path to package directory")

using Pkg

Pkg.activate("./")

using OPFSampler
using PowerModels
```
Parsing the power grid:
```
base_model = PowerModels.parse_file("path to PowerModel case data.");
```

setting a dictionary of parameters that include the case name,
for which the samples are to be generated along with the selected $0 \leq \delta \leq 1$ for each parameter that is varied. Here we have chosen $10\%$ deviation for all the parameters as an example.

```
params = Dict("case_network" => base_model, "dev_load_pd" => 0.1,
              "dev_gen_max" => 0.1, "dev_rate_a" => 0.1, "dev_br_x" => 0.1);
```
Finally running the sampler and getting the feasible DC-OPF samples:
```
num_of_samples = 5; # number of required OPF samples.
samples = RunDCSampler(num_of_samples, params);
```
The sampling function starts by generating the number of required samples and then runs OPF for each of the samples and filter those with feasible OPF solutions. Since some of the generated samples might not be feasible, the sample generation continues in an iterative manner until the required number of samples with feasible solution is met. Currently, if more than 60\% of the samples lead to infeasible OPF in the first iteration, the algorithm returns an error to indicate the fact that the choice of parameters might not be suitable for the used grid.    

#### Output Structure
The output data `samples` is an array of dictionaries where each element of array has the corresponding sample parameter values and the OPF solution. For each input parameter type (e.g., "price_insensitive_load"), the order of array of data is based on the sorted keys of the original data in the `base_model` for the "price_insensitive_load".  
## AC Sampler
The AC sampler gives you the functionality to vary the grid parameters by rescaling them using factors drawn from uniform distribution of the form $\mathcal{U}(1-\delta, 1+\delta)$. The user is able to re-scale the following parameters:

* nodal load active power,
* nodal load reactive power,
* maximum active power output of generators,
* maximum reactive power output of generators,
* line thermal ratings,
* line reactance values,
* line resistance values.

#### Minimal Working Example in Julia
Setting up the path and activating the package:
```
cd("path to package directory")

using Pkg

Pkg.activate("./")

using OPFSampler
using PowerModels
```
Parsing the power grid:
```
base_model = PowerModels.parse_file("path to PowerModel case data.");
```

setting a dictionary of parameters that include the case name,
for which the samples are to be generated along with the selected $0 \leq \delta \leq 1$ for each parameter that is varied. Here we have chosen $10\%$ deviation for all the parameters as an example.

```
params = Dict("case_network" => base_model, "dev_load_pd" => 0.1,
               "dev_load_qd" => 0.1, "dev_pgen_max" => 0.1, "dev_qgen_max" => 0.1,
               "dev_rate_a" => 0.1, "dev_br_x" => 0.1, "dev_br_r" => 0.1);
```
Finally running the sampler and getting the feasible AC-OPF samples:
```
num_of_samples = 5; # number of required OPF samples.
samples = RunACSampler(num_of_samples, params);
```
The sampling function starts by generating the number of required samples and then runs OPF for each of the samples and filter those with feasible OPF solutions. Since some of the generated samples might not be feasible, the sample generation continues in an iterative manner until the required number of samples with feasible solution is met. Currently, if more than 60\% of the samples lead to infeasible OPF in the first iteration, the algorithm returns an error to indicate the fact that the choice of parameters might not be suitable for the used grid.    

#### Output Structure
The output data `samples` is an array of dictionaries where each element of array has the corresponding sample parameter values and the OPF solution. For each input parameter type (e.g., "price_insensitive_qload"), the order of array of data is based on the sorted keys of the original data in the `base_model` for the "price_insensitive_load".  

## Grid Clean-Up Functions
In order to avoid creating samples for elements of the grid that are either disabled or not relevant, there are two functions `grid_dcopf_cleanup!()`  and `grid_acopf_cleanup!()` that take the PowerModel parsed grid as input and clean up the irrelevant elements.
For DC-OPF, the function removes all the disabled branches and generators that are either disabled or have $p_{min}=p_{max}=0$. For AC-OPF, the function removes all the disabled branches and generators that are either disabled or have $p_{min}=p_{max}=q_{min}=q_{max}=0$.

These function can be called before running the sampler.
```
base_model = PowerModels.parse_file("path to PowerModel case data.");
grid_dcopf_cleanup!(base_model) # for DC-OPF
grid_acopf_cleanup!(base_model) # for AC-OPF
```

## How to Use Generated Samples?
There are functions provided in the package to vary the parameters of the original grid by the values generated in the `samples`, and run OPF or do other analysis.

Let's assume that the vector of `samples` are created and we want to change the grid parameters to those in the $i-th$ sample:

#### DC-OPF Example:
```
base_model = PowerModels.parse_file("path to PowerModel case data.");
OPFSampler.set_load_pd!(base_model, samples[i]["price_insensitive_load"])
OPFSampler.set_gen_pmax!(base_model, samples[i]["pg_max"])
OPFSampler.set_dc_branch_param!(base_model, br_x = samples[i]["br_x"],
rate_a = samples[i]["rate_a"])
```

#### AC-OPF Example:
```
base_model = PowerModels.parse_file("path to PowerModel case data.");
OPFSampler.set_load_pd!(base_model, samples[i]["price_insensitive_pload"])
OPFSampler.set_load_qd!(base_model, samples[i]["price_insensitive_qload"])
OPFSampler.set_gen_pmax!(base_model, samples[i]["pg_max"])
OPFSampler.set_gen_qmax!(base_model, samples[i]["qg_max"])
OPFSampler.set_ac_branch_param!(base_model, br_x = samples[i]["br_x"],
                                br_r = samples[i]["br_r"], rate_a = samples[i]["rate_a"])
```

Note that for either DC or AC case, if the use only needs the OPF solution with the varied parameter, he/she can use the "OPF_output" key in the `samples[i]` dictionary which is the solution of the OPF when the input parameters are changed according to `samples[i]`.
