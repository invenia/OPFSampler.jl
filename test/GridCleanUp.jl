@testset "Grid clean-up tests" begin
    base_model = PowerModels.parse_file("./data/pglib_opf_case30_ieee.m")
    pm_model = deepcopy(base_model)
    pm_model["gen"]["1"]["gen_status"] = 0
    pm_model["branch"]["29"]["br_status"] = 0
    OPFSampler.grid_dcopf_cleanup!(pm_model)
    # generator "6" is one of the generators that should be cleand up in this testcase.
    @test haskey(base_model["gen"], "6") != haskey(pm_model["gen"], "6")
    @test haskey(base_model["gen"], "1") != haskey(pm_model["gen"], "1")
    @test haskey(base_model["branch"], "29") != haskey(pm_model["branch"], "29")
    pm_model = deepcopy(base_model)
    pm_model["gen"]["1"]["gen_status"] = 0
    pm_model["branch"]["29"]["br_status"] = 0
    pm_model["gen"]["2"]["pmax"] = pm_model["gen"]["2"]["pmin"] = 0
    pm_model["gen"]["5"]["pmax"] = pm_model["gen"]["5"]["pmin"] = 0
    pm_model["gen"]["5"]["qmax"] = pm_model["gen"]["5"]["qmin"] = 0
    OPFSampler.grid_acopf_cleanup!(pm_model)
    @test haskey(base_model["gen"], "1") != haskey(pm_model["gen"], "1")
    @test haskey(base_model["gen"], "5") != haskey(pm_model["gen"], "5")
    @test haskey(base_model["gen"], "2") == haskey(pm_model["gen"], "2")
    @test haskey(base_model["branch"], "29") != haskey(pm_model["branch"], "29")
end
