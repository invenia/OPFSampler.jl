"""
    function grid_dcopf_cleanup!(power_model::Dict)
This function takes grid parameters and remove the generators that have either
p_max = p_min = 0 or have gen_status = 0. It also removes branches that are disabled.

# Arguments:
- `power_model::Dict`: Grid data in PowerModels.jl format.

"""
function grid_dcopf_cleanup!(power_model::Dict)
    for k_ in keys(power_model["branch"])
        if power_model["branch"][k_]["br_status"] == 0
            delete!(power_model["branch"], k_)
        end
    end
    for k_ in keys(power_model["gen"])
        if (power_model["gen"][k_]["pmax"] == power_model["gen"][k_]["pmin"] == 0) || (power_model["gen"][k_]["gen_status"] == 0)
            delete!(power_model["gen"], k_)
        end
    end
end

"""
    function grid_acopf_cleanup!(power_model::Dict)
This function takes grid parameters and remove the generators that have either
p_max = p_min = q_min = q_max = 0 or have gen_status = 0. It also removes branches that are disabled.

# Arguments:
- `power_model::Dict`: Grid data in PowerModels.jl format.

"""
function grid_acopf_cleanup!(power_model::Dict)
    for k_ in keys(power_model["branch"])
        if power_model["branch"][k_]["br_status"] == 0
            delete!(power_model["branch"], k_)
        end
    end
    for k_ in keys(power_model["gen"])
        if (power_model["gen"][k_]["gen_status"] == 0) || (power_model["gen"][k_]["pmax"] == power_model["gen"][k_]["pmin"] == power_model["gen"][k_]["qmax"] == power_model["gen"][k_]["qmin"] == 0)
            delete!(power_model["gen"], k_)
        end
    end
end
