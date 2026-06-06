module Diversinet

# dependencies
using PhyloNetworks, Distributions

include("DiversinetInterface.jl")
using .DiversinetInterface

# my code
include("ModelStruct.jl")
include("Likelihood.jl")
include("Simulator.jl")
include("JitterNetwork.jl")
include("ComputeKmax.jl")

end
