# OPFSampler

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://invenia.github.io/OPFSampler.jl/stable)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://invenia.github.io/OPFSampler.jl/dev)
[![Build Status](https://travis-ci.com/invenia/OPFSampler.jl.svg?branch=master)](https://travis-ci.com/invenia/OPFSampler.jl)
[![Build Status](https://ci.appveyor.com/api/projects/status/github/invenia/OPFSampler.jl?svg=true)](https://ci.appveyor.com/project/invenia/OPFSampler-jl)
[![Codecov](https://codecov.io/gh/invenia/OPFSampler.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/invenia/OPFSampler.jl)

# Goal
The goal of the package is to provide functions that take a power grid as input, vary its parameters and generate feasible DC- and AC-OPF samples along with the corresponding solutions. This helps the user to explore a variety of distinct active sets of constraints of synthetic cases and mimic the time-varying behavior of the OPF input parameters.

## Sampler
`RunDCSampler()` and `RunACSampler()` are the two main functions that generate DC- and AC-OPF samples, respectively.
The sampler functions provide the functionality to vary the grid parameters by rescaling them using factors drawn from a uniform distribution of the form <img src="https://render.githubusercontent.com/render/math?math=\mathcal{U}(1-\delta, 1%2B\delta)">. The following parameters can be rescaled for DC-OPF:

* nodal load active power
* maximum active power output of generators
* line thermal ratings
* line reactance values.

**In addition** to the parameters above, the following can also be changed for AC-OPF:
* nodal load reactive power
* maximum reactive power output of generators
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
for which the samples are to be generated along with the selected <img src="https://render.githubusercontent.com/render/math?math=0 \leq \delta \leq 1"> for each parameter that is varied. Here we have chosen 10\% deviation for all the parameters as an example.

```
# DC Parameters
params_DC = Dict("case_network" => base_model, "dev_load_pd" => 0.1,
              "dev_gen_max" => 0.1, "dev_rate_a" => 0.1, "dev_br_x" => 0.1);

# AC Parameters              
params_AC = Dict("case_network" => base_model, "dev_load_pd" => 0.1,
               "dev_load_qd" => 0.1, "dev_pgen_max" => 0.1, "dev_qgen_max" => 0.1,
               "dev_rate_a" => 0.1, "dev_br_x" => 0.1, "dev_br_r" => 0.1);
```
Finally running the sampler and getting the feasible OPF samples:
```
num_of_samples = 5; # number of required OPF samples.

# DC-OPF
samples = RunDCSampler(num_of_samples, params_DC);

# AC-OPF
samples = RunACSampler(num_of_samples, params_AC);
```
The sampling function starts by generating the number of required samples and then runs OPF for each of the samples and filter those with feasible OPF solutions. Importing power grid data, grid modifications and solving OPF are all done within [PowerModels.jl](https://github.com/lanl-ansi/PowerModels.jl) framework. Since some of the generated samples might not be feasible, the sample generation continues in an iterative manner until the required number of samples with feasible solution is met. Currently, if more than 60\% of the samples lead to infeasible OPF in the first iteration, the algorithm returns an error to indicate the fact that the choice of parameters might not be suitable for the used grid.    

#### Output Structure
The output data `samples` is an array of dictionaries where each element of array has the corresponding sample parameter values and the OPF solution. For each input parameter type, the order of array of data is based on the sorted dictionary of the original data in the `base_model`. For examples, `samples[i]["rate_a"]` is a vector containing the thermal rating branch values in sample i and the order is the same order of the keys in `sort(base_model["branch"])`. Or `samples[i]["qd"]` is a vector containing the load reactive power values in sample i and the order is the same order of the keys in `sort(base_model["load"])`.

For sample i in the dictionary, depending on the type of sampler (AC/DC), all or a subset of the following keys can be found:

* "pd" : nodal load active power
* "qd" : nodal load reactive power
* "pmax" : maximum active power output of generators
* "qmax" : maximum reactive power output of generators
* "rate_a" : line thermal ratings
* "br_x" : line reactance values
* "br_r" : line resistance values.
* "OPF_output" : OPF solution for the corresponding sample in PowerModels format.

The key names are compatible with the keys of corresponding data in [PowerModels.jl](https://github.com/lanl-ansi/PowerModels.jl).
## Grid Clean-Up Functions
In order to avoid creating samples for elements of the grid that are either disabled or not relevant, there are two functions `grid_dcopf_cleanup!()`  and `grid_acopf_cleanup!()` that take the PowerModel parsed grid as input and clean up these irrelevant elements.
For DC-OPF, the function removes all the disabled branches and generators that are either disabled or have <img src="https://render.githubusercontent.com/render/math?math=p_{min}=p_{max}=0">. For AC-OPF, the function removes all the disabled branches and generators that are either disabled or have <img src="https://render.githubusercontent.com/render/math?math=p_{min}=p_{max}=q_{min}=q_{max}=0">.

These function should be called before running the sampler.
```
base_model = PowerModels.parse_file("path to PowerModel case data.");
grid_dcopf_cleanup!(base_model) # for DC-OPF
grid_acopf_cleanup!(base_model) # for AC-OPF
```

## Generated Data Samples
Using the sampler code above, we have generated input samples for different grid cases in the [pglib-opf library](https://github.com/power-grid-lib/pglib-opf). All the input samples have been tested to make sure they have feasible OPF solution. Table below shows the list of grids and available input sample size for each grid:

| Grid         | DC Sample Size | AC Sample Size |
|--------------|----------------|----------------|
| 24-ieee-rts  |       10k      |       1k       |
| 30-ieee      |       10k      |       1k       |
| 39-epri      |       10k      |       1k       |
| 57-ieee      |       10k      |       1k       |
| 73-ieee-rts  |       10k      |       1k       |
| 118-ieee     |       10k      |       1k       |
| 162-ieee-dtc |       10k      |       1k       |
| 300-ieee     |       10k      |       1k       |
| 588-sdet     |       10k      |       1k       |
| 1354-pegase  |       10k      |       1k       |
| 2853-sdet    |       10k      |        -       |
| 4661-sdet    |       10k      |        -       |
| 9241-pegase  |       10k      |        -       |


You can access the samples in the following [link]().

In the generated samples above, the OPF solution that is generated under "OPF_output" has been removed to keep the size of the data small. 
## How to Use Generated Samples?
There are functions provided in the package to vary the parameters of the original grid by the values generated in the `samples`, and run OPF or perform other analysis.

Let's assume that the vector of `samples` are created and we want to change the grid parameters to those in the i-th sample:

#### DC-OPF Example:
```
base_model = PowerModels.parse_file("path to PowerModel case data.");
OPFSampler.set_load_pd!(base_model, samples[i]["pd"])
OPFSampler.set_gen_pmax!(base_model, samples[i]["pmax"])
OPFSampler.set_dc_branch_param!(base_model, br_x = samples[i]["br_x"],
rate_a = samples[i]["rate_a"])
```

#### AC-OPF Example:
```
base_model = PowerModels.parse_file("path to PowerModel case data.");
OPFSampler.set_load_pd!(base_model, samples[i]["pd"])
OPFSampler.set_load_qd!(base_model, samples[i]["qd"])
OPFSampler.set_gen_pmax!(base_model, samples[i]["pmax"])
OPFSampler.set_gen_qmax!(base_model, samples[i]["qmax"])
OPFSampler.set_ac_branch_param!(base_model, br_x = samples[i]["br_x"],
                                br_r = samples[i]["br_r"], rate_a = samples[i]["rate_a"])
```

**Important Note:** The samples above are generated on grids after calling the corresponding clean-up functions so the `base_model` should be passed through the clean-up functions before varying its parameters by the above set-functions.
