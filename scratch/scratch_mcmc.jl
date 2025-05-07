using Diversinet
using PhyloNetworks, PhyloPlots, RCall, DelimitedFiles;
using Distributions
using AdaptiveMCMC
using MCMCChains, StatsPlots

# true values
lambda = 1.0
mu     = 0.5
psi    = 0.001
rho    = 1.0
t      = 7.0

# simulate a network
newick  = Diversinet.simulate(t, 1, λ = lambda, μ = mu, ψ = psi, ρ = rho, condition = Diversinet.Tree)[1];
network = PhyloNetworks.readnewick(newick);

# write the network
this_fn = "scratch/test_net.tre";
writedlm(this_fn, [newick]);

# plot the network
R"pdf"("scratch/test_net.pdf", height = 6, width = 6)
R"par"(mar = [0,0,0,0])
PhyloPlots.plot(network, useedgelength = true)
R"dev.off()";

# make function
function log_lik(x)
    
    # compute likelihood
    lnl = Diversinet.computeLogLikelihood(newick, λ = x[1], μ = x[2], ψ = x[3], ρ = rho, kmax = 64)
    
    # println(lnl)

    return lnl

end;

function log_pr(x)

    # compute the prior probabilities
    lnp  = logpdf(LogUniform(1e-4, 4), x[1])
    lnp += logpdf(LogUniform(1e-4, 4), x[2])
    lnp += logpdf(LogUniform(1e-4, 4), x[3])

    return lnp
    
end;

log_lik([lambda, mu, psi])

log_lik([1.0, 0.5, 0.02])
log_pr([1.0, 0.5, 0.02])

# run MCMC
x0 = [lambda, mu, psi];
out = adaptive_rwm(x0, log_lik, 100_000; log_pr = log_pr, thin = 10, algorithm = :aswam, progress = true, fulladapt = false);

# plot
c = Chains(out.X', start = out.params.b, thin = out.params.thin); StatsPlots.plot(c)

# d = Chains(out.D[1], start = out.params.b, thin = out.params.thin); StatsPlots.plot(d)

x0

mean(out.X[1,:])
mean(out.X[2,:])
mean(out.X[3,:])

mean(out.X[1,:] .- out.X[2,:])
mean(out.X[2,:] ./ out.X[1,:])

