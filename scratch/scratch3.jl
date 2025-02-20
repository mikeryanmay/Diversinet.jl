using Diversinet
using PhyloNetworks

# get a newick string
newick = "(((t_3:0.0264992476)#P1:0.0000000000,t_1:0.0264992476):0.2968978190,(#P1:0.0000000000,t_2:0.0264992476):0.2968978190):0.6766029334;"

# create the model objects
model = Diversinet.DiversinetModel(newick, λ = 1.0, μ = 0.5, ψ = 0.01, ρ = 1.0)

# compute the likelihood
Diversinet.computeLikelihood!(model)

