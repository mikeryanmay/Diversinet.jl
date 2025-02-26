@enum Condition begin
    Time = 1
    Survival = 2
    Tree = 3
    Hybrid = 4
end

function simulate(time::Float64,
                  reps::Int;
                  λ::Float64 = 1.0,
                  μ::Float64 = 0.0,
                  η::Float64 = 0.0,
                  ζ::Float64 = 0.0,
                  ν::Float64 = 0.0,
                  ψ::Float64 = 0.0,
                  ρ::Float64 = 1.0,
                  condition::Condition = Time,
                  max::Int64 = 1000)

    # domain checking
    reps < 1 && throw(DomainError("reps must be >= 1."))
    time <= 0 && throw(DomainError("time must be > 0."))
    λ < 0 && throw(DomainError("λ must be >= 0."))
    μ < 0 && throw(DomainError("μ must be >= 0."))
    η < 0 && throw(DomainError("η must be >= 0."))
    ζ < 0 && throw(DomainError("ζ must be >= 0."))
    ν < 0 && throw(DomainError("ν must be >= 0."))
    ψ < 0 && throw(DomainError("ψ must be >= 0."))
    ρ < 0 && throw(DomainError("ρ must be between 0 and 1."))
    ρ > 1 && throw(DomainError("ρ must be between 0 and 1."))

    # get the condition
    if condition == Time
        cond = "none"
    elseif condition == Survival
        cond = "survival"
    elseif condition == Tree
        cond = "tree"
    elseif condition == Hybrid
        cond = "tree+hybrid"
    end

    # create the simulator
    interface = DiversinetInterface.Diversinet!Interface!DiversinetInterface()
    
    # set the parameters
    DiversinetInterface.setLambda(interface, λ)
    DiversinetInterface.setMu(interface, μ)
    DiversinetInterface.setEta(interface, η)
    DiversinetInterface.setZeta(interface, ζ)
    DiversinetInterface.setNu(interface, ν)
    DiversinetInterface.setPsi(interface, ψ)
    DiversinetInterface.setRho(interface, ρ)

    # do the simulations
    networks = Array{String}(undef, reps)
    for i in 1:reps

        # simulate the newick
        network = DiversinetInterface.simulate(interface, time, cond, -1, true, max)

        # store
        networks[i] = String(network)

    end

    # return the container
    return networks

end