using Pkg; Pkg.activate(".");

using Diversinet;
using DiversinetInterface;
using PhyloNetworks, PhyloPlots, RCall, DelimitedFiles, Optim, Suppressor;

# get parameters
lambda = 0.01719833;
psi    = 0.0003252187;
# lambda = 0.00001;
# psi    = 1.0;

# read newick
newick = "(((t_3:36.0948967740)#P1:0.0000000000,(t_4:9.5951359694,t_5:9.5951359694):26.4997608046):63.9051032260,((#P1:0.0000000000,t_2:36.0948967740):13.4660281028,t_1:49.5609248769):50.4390751231):0.0000000000;";

lnl = Diversinet.computeLogLikelihood(newick, λ = lambda, ψ = psi, ρ = 1.0, kmax = 2)

println(lnl)

