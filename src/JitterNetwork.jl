function jitterNetwork(newick::String, factor::Float64 = 1e-4)

    # make the interface
    interface = DiversinetInterface.Diversinet!Interface!DiversinetInterface()

    # jitter the tree
    new_newick = DiversinetInterface.jitterNewick(interface, newick, factor)

    return String(new_newick)

end