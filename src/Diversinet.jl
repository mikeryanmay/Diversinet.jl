module Diversinet

# dependencies
using PhyloNetworks, DiversinetInterface, Distributions

# my code
include("ModelStruct.jl")
include("Likelihood.jl")
include("Simulator.jl")
include("JitterNetwork.jl")
include("computeKmax.jl")

end
