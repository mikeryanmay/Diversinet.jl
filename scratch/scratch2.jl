using Diversinet
using PhyloNetworks

# get a newick string
newick = "(((t_2:0.3082252749,t_3:0.3082252749):0.4687703178)#LGT1:0.1175871878,(#LGT1:0.0000000000,t_1:0.7769955927):0.1175871878):0.1054172195;"

# turn the newick string into a network
network = PhyloNetworks.readnewick(newick)

# create the model objects
model1 = Diversinet.DiversinetModel(newick, λ = 1.0, μ = 0.5, η = 0.1, ρ = 1.0)
model2 = Diversinet.DiversinetModel(network)

# try some likelihoods
Diversinet.computeLikelihood!(model1)

using DiversinetInterface
int = DiversinetInterface.Diversinet!Interface!DiversinetInterface()
DiversinetInterface.setLambda(int, 1.0)
DiversinetInterface.setMu(int, 0.5)
DiversinetInterface.setEta(int, 0.1)
DiversinetInterface.setRho(int, 1.0)
DiversinetInterface.readNewick(int, newick)
DiversinetInterface.computeLogLikelihood(int)



# try setting some invalid parameters
Diversinet.setLambda!(model1, -0.5)
Diversinet.setLambda!(model1, 0.5)

Diversinet.setMu!(model1, -0.5)
Diversinet.setMu!(model1, 0.5)

Diversinet.setEta!(model1, -0.5)
Diversinet.setEta!(model1, 0.5)

Diversinet.setZeta!(model1, -0.5)
Diversinet.setZeta!(model1, 0.5)

Diversinet.setNu!(model1, -0.5)
Diversinet.setNu!(model1, 0.5)

Diversinet.setPsi!(model1, -0.5)
Diversinet.setPsi!(model1, 0.5)

Diversinet.setRho!(model1, -0.5)
Diversinet.setRho!(model1, 1.5)
Diversinet.setNu!(model1, 0.5)