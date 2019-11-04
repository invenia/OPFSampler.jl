using Ipopt
using JuMP
using OPFSampler
using OrderedCollections # Define sort on dict
using PowerModels
using Random
using Test

PowerModels.silence()

@testset "OPFSampler.jl" begin
    include("SetParam.jl")
    include("GridCleanUp.jl")
    include("Sampler.jl")
end
