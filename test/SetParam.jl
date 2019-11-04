@testset "SetParam.jl tests" begin
    base_model = PowerModels.parse_file("./data/case9.m")
    pm_model = deepcopy(base_model)
    base_pload = [pm_model["load"][k]["pd"] for k in keys(sort(pm_model["load"]))]
    OPFSampler.set_load_pd!(pm_model, 2 * base_pload)
    new_pload = [pm_model["load"][k]["pd"] for k in keys(sort(pm_model["load"]))]
    @test new_pload == 2 * base_pload
    base_qload = [pm_model["load"][k]["qd"] for k in keys(sort(pm_model["load"]))]
    OPFSampler.set_load_qd!(pm_model, 2 * base_qload)
    new_qload = [pm_model["load"][k]["qd"] for k in keys(sort(pm_model["load"]))]
    @test new_qload == 2 * base_qload
    base_pgmax = [pm_model["gen"][k]["pmax"] for k in keys(sort(pm_model["gen"]))]
    OPFSampler.set_gen_pmax!(pm_model, 2 * base_pgmax)
    new_pgmax = [pm_model["gen"][k]["pmax"] for k in keys(sort(pm_model["gen"]))]
    @test new_pgmax == 2 * base_pgmax
    base_qgmax = [pm_model["gen"][k]["qmax"] for k in keys(sort(pm_model["gen"]))]
    OPFSampler.set_gen_qmax!(pm_model, 2 * base_qgmax)
    new_qgmax = [pm_model["gen"][k]["qmax"] for k in keys(sort(pm_model["gen"]))]
    @test new_qgmax == 2 * base_qgmax
    base_br_x = [pm_model["branch"][k]["br_x"] for k in keys(sort(pm_model["branch"]))]
    base_rate_a = [pm_model["branch"][k]["rate_a"] for k in keys(sort(pm_model["branch"]))]
    OPFSampler.set_dc_branch_param!(pm_model, br_x = 2 * base_br_x,
    rate_a = 2 * base_rate_a)
    new_br_x = [pm_model["branch"][k]["br_x"] for k in keys(sort(pm_model["branch"]))]
    new_rate_a = [pm_model["branch"][k]["rate_a"] for k in keys(sort(pm_model["branch"]))]
    @test new_br_x == 2 * base_br_x
    @test new_rate_a == 2 * base_rate_a
    base_br_x = [pm_model["branch"][k]["br_x"] for k in keys(sort(pm_model["branch"]))]
    base_br_r = [pm_model["branch"][k]["br_r"] for k in keys(sort(pm_model["branch"]))]
    base_rate_a = [pm_model["branch"][k]["rate_a"] for k in keys(sort(pm_model["branch"]))]
    OPFSampler.set_ac_branch_param!(pm_model, br_x = 2 * base_br_x,
    br_r = 2 * base_br_r, rate_a = 2 * base_rate_a)
    new_br_x = [pm_model["branch"][k]["br_x"] for k in keys(sort(pm_model["branch"]))]
    new_br_r = [pm_model["branch"][k]["br_r"] for k in keys(sort(pm_model["branch"]))]
    new_rate_a = [pm_model["branch"][k]["rate_a"] for k in keys(sort(pm_model["branch"]))]
    @test new_br_x == 2 * base_br_x
    @test new_br_r == 2 * base_br_r
    @test new_rate_a == 2 * base_rate_a
end
