function set_load_pd!(
    power_model::Dict,
    new_pd::AbstractArray,
    )
    for (k, (i, load)) in enumerate(sort(power_model["load"]))
        load["pd"] = new_pd[k]
    end
end

function set_load_qd!(
    power_model::Dict,
    new_qd::AbstractArray,
    )
    for (k, (i, load)) in enumerate(sort(power_model["load"]))
        load["qd"] = new_qd[k]
    end
end

function set_gen_pmax!(
    power_model::Dict,
    new_pgmax::AbstractArray,
    )
    for (k, (i, gen)) in enumerate(sort(power_model["gen"]))
        gen["pmax"] = new_pgmax[k]
    end
end

function set_gen_qmax!(
    power_model::Dict,
    new_qgmax::AbstractArray,
    )
    for (k, (i, gen)) in enumerate(sort(power_model["gen"]))
        gen["qmax"] = new_qgmax[k]
    end
end

function set_dc_branch_param!(
    power_model::Dict;
    br_x::AbstractArray,
    rate_a::AbstractArray,
    )
    for (k, (i, branch)) in enumerate(sort(power_model["branch"]))
        branch["br_x"] = br_x[k]
        branch["rate_a"] = rate_a[k]
    end
end

function set_ac_branch_param!(
    power_model::Dict;
    br_x::AbstractArray,
    br_r::AbstractArray,
    rate_a::AbstractArray,
    )
    for (k, (i, branch)) in enumerate(sort(power_model["branch"]))
        branch["br_x"] = br_x[k]
        branch["br_r"] = br_r[k]
        branch["rate_a"] = rate_a[k]
    end
end
