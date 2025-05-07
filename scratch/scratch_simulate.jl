using Diversinet
using PhyloNetworks, DelimitedFiles;

# parameters
lambda = 0.5
mu = 0.0
rho = 1.0
psi = 0.015
time = 4.0
reps = 10

# Diversinet.simulate(1.0, 1, λ = lambda, μ = mu, ψ = psi, ρ = rho, condition = Diversinet.Tree, root = false)[1]
# Diversinet.simulate(1.0, 1, λ = lambda, μ = mu, ψ = psi, ρ = rho, condition = Diversinet.Tree, root = true)[1]

# simulations
networks = Diversinet.simulate(time, reps, λ = lambda, μ = mu, ψ = psi, ρ = rho, condition = Diversinet.Hybrid);

# write the networks
for i in eachindex(networks)
    this_network = networks[i]
    this_fn = "scratch/test_nets/net_$i.tre"
    writedlm(this_fn, [this_network])
end