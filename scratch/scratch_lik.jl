using Diversinet
using PhyloNetworks, PhyloPlots, RCall, DelimitedFiles;
using Distributions
using AdaptiveMCMC
using MCMCChains, StatsPlots

# true values
lambda = 0.5
mu     = 0.1
psi    = 0.0
rho    = 0.5
t      = 10.0

# make the network
newick = "((A:0.5,B:0.5):0.25,C:0.75):0.25;"

# compute the likelihood
Diversinet.computeLogLikelihood(newick, λ = lambda, μ = mu, ρ = rho)
