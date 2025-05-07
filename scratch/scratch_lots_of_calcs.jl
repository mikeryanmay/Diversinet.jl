using Pkg;
Pkg.activate(".")

using Diversinet;
using PhyloNetworks, PhyloPlots, RCall, DelimitedFiles, Optim, Suppressor;

# true parameters
lambda = 0.5;
mu     = 0.1;
psi    = 0.0001;
rho    = 1.0;
t      = 7.0;

# simulate a bunch of networks
reps = 1000
for i in 1:reps

    println("simulation $i")

    # simulate a network
    newick = Diversinet.simulate(t, 1, λ = lambda, μ = mu, ψ = psi, ρ = rho, condition = Diversinet.Hybrid)[1];

    println("simulation done.")

    # make a network
    network = @suppress begin
        PhyloNetworks.readnewick(newick);
    end

    # store and plot the network
    println("plotting tree")
    this_fn = "scratch/test/test_net_$i.tre";
    writedlm(this_fn, [newick]);

    # plot the network
    R"pdf"("scratch/test/plot_net_$i.pdf", height = 6, width = 6)
    R"par"(mar = [0,0,0,0])
    plot(network, useedgelength = true)
    R"axis"(1)
    R"dev.off()";

    # compute a likelihood
    println("computing likelihood")
    lnl = Diversinet.computeLogLikelihood(newick, λ = lambda, μ = mu, ψ = psi, ρ = rho, kmax = 64)

    # check for jittering
    if lnl < -1e100

        println("\thad to jitter. here are some lnls for various jitters")
        for j in 1:10
            
            # jitter
            new_newick = Diversinet.jitterNetwork(newick);

            # compute likelihood
            lnl = Diversinet.computeLogLikelihood(new_newick, λ = lambda, μ = mu, ψ = psi, ρ = rho, kmax = 64)

            println("\tlikelihood (jitter $j) = $lnl")

        end

    else
        println("\tlikelihood = $lnl")
    end

    
    
end