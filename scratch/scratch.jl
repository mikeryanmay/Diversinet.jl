import DiversinetInterface;
using PhyloNetworks, PhyloPlots;

# make an interface object
int = DiversinetInterface.Diversinet!Interface!DiversinetInterface()

# set some parameters
lambda = 1.0
mu = 0.5
rho = 1.0
psi = 0.01

DiversinetInterface.setLambda(int, lambda)
DiversinetInterface.setMu(int, mu)
DiversinetInterface.setPsi(int, psi)
DiversinetInterface.setRho(int, rho)

# newick = DiversinetInterface.simulate(int, 1.0, "tree+hybrid", 1, false)
newick = DiversinetInterface.simulate(int, 1.0, "tree+hybrid", -1, true)
newick_string = String(newick)
println(newick_string)

# # read the newick string as a PhyloNetworks network
net = PhyloNetworks.readnewick(newick_string)

using RCall
R"pdf"("network.pdf", height = 4, width = 4)
R"par"(mar = [0,0,0,0])
plot(net, useedgelength = true)
R"dev.off()"


# send it back to Diversinet
DiversinetInterface.readNewick(int, newick_string)
lnl = DiversinetInterface.computeLogLikelihood(int)
println(lnl)
