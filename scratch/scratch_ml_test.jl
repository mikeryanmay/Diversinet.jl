using Diversinet;
using PhyloNetworks, PhyloPlots, RCall, DelimitedFiles, Optim;

# true parameters
lambda = 0.5;
mu     = 0.1;
psi    = 0.001;
rho    = 1.0;
t      = 7.0;

# simulate a network
newick  = Diversinet.simulate(t, 1, λ = lambda, μ = mu, ψ = psi, ρ = rho, condition = Diversinet.Hybrid)[1];
network = PhyloNetworks.readnewick(newick);

Diversinet.computeLogLikelihood(newick, λ = lambda, μ = mu, ψ = psi, ρ = rho, kmax = 64)

# write the network
this_fn = "scratch/test_net.tre";
writedlm(this_fn, [newick]);

# plot the network
R"pdf"("scratch/test_net.pdf", height = 6, width = 6)
R"par"(mar = [0,0,0,0])
plot(network, useedgelength = true)
R"dev.off()";

# make a closure
function llf(params)
    
    # check bounds
    if params[1] < 0
        return Inf
    end
    if params[2] < 0
        return Inf
    end
    if params[3] < 0
        return Inf
    end

    # compute likelihood
    lnl = Diversinet.computeLogLikelihood(newick, λ = params[1], μ = params[2], ψ = params[3], ρ = rho, kmax = 64)
    return -lnl

end;

llf([1.0, 0.5, 0.02])
llf([1.0, 0.5, 0.01])
llf([1.0, 0.5, 0.01])
llf([2.0, 0.5, 0.01])
llf([2.0, 0.5, 0.01])
llf([2.0, 0.5, 0.02])

# x0 = [0.1, 0.05, 0.01];
x0 = [lambda, mu, psi];
fit = Optim.optimize(llf, x0, Optim.Options(show_trace = true, show_every = 10, f_tol = 1e-2, iterations = 1000, trace_simplex = true))
Optim.minimizer(fit)