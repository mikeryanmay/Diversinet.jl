@enum Condition begin
	Nothing = 0
	RootSurvival = 1
	RootMRCA = 2
	StemSurvival = 3
	StemTwoSamples = 4
end

mutable struct DiversinetModel
    
    # the network
    newick::String;
    
    # parameters
    λ::Float64;
    μ::Float64;
    η::Float64;
    ζ::Float64;
    ν::Float64;
    ψ::Float64;
    ρ::Float64;

    # numerical settings
    kmax::Int64;

    # conditioning
    cond::Condition;

    # flags
    λ_dirty::Bool;
    μ_dirty::Bool;
    η_dirty::Bool;
    ζ_dirty::Bool;
    ν_dirty::Bool;
    ψ_dirty::Bool;
    ρ_dirty::Bool;
    k_dirty::Bool;
    cond_dirty::Bool;
    
    # the tp instance
    tp::DiversinetInterface.Diversinet!Interface!DiversinetInterfaceAllocated;

    # constructor (newick string)
    function DiversinetModel(network::String;
                             λ::Float64  = 1.0,
                             μ::Float64  = 0.0,
                             η::Float64  = 0.0,
                             ζ::Float64  = 0.0,
                             ν::Float64  = 0.0,
                             ψ::Float64  = 0.0,
                             ρ::Float64  = 1.0,
                             kmax::Int64 = 128,
                             cond::Condition = Nothing)

        # make the struct
        x = new()

        # associate finalizer
        finalizer(releaseMemory, x)

        # make a new tp instance
        x.tp = DiversinetInterface.Diversinet!Interface!DiversinetInterface();

        # assign the newick
        x.newick = network
        DiversinetInterface.readNewick(x.tp, network)

        # assign parameters
        setLambda!(x, λ)
        setMu!(x, μ)
        setEta!(x, η)
        setZeta!(x, ζ)
        setNu!(x, ν)
        setPsi!(x, ψ)
        setRho!(x, ρ)
        setKmax!(x, kmax)
        setConditionalProbabilityType!(x, cond)

        # prepare the interface
        prepareModel!(x)

        # done
        return x

    end

    # constructor (Phylonetworks object)
    function DiversinetModel(network::HybridNetwork;
                             λ::Float64  = 1.0,
                             μ::Float64  = 0.0,
                             η::Float64  = 0.0,
                             ζ::Float64  = 0.0,
                             ν::Float64  = 0.0,
                             ψ::Float64  = 0.0,
                             ρ::Float64  = 1.0,
                             kmax::Int64 = 128,
                             cond::Condition = Nothing)

        # check the network
        !network.isrooted && throw(ArgumentError("Network is not rooted"))

        # get the newick string
        newick = PhyloNetworks.writenewick(network)

        # create the object with the newick string
        return DiversinetModel(newick, λ = λ, μ = μ, η = η, ζ = ζ, ν = ν, ψ = ψ, ρ = ρ, kmax = kmax, cond = cond)

    end

end

function releaseMemory(obj::DiversinetModel)
    finalize(obj.tp)
end


function setLambda!(model::DiversinetModel, λ::Float64)
    λ < 0 && throw(DomainError("setLambda called with negative λ."))
    model.λ = λ
    model.λ_dirty = true;
end

function setMu!(model::DiversinetModel, μ::Float64)
    μ < 0 && throw(DomainError("setMu called with negative μ."))
    model.μ = μ
    model.μ_dirty = true;
end

function setEta!(model::DiversinetModel, η::Float64)
    η < 0 && throw(DomainError("setEta called with negative η."))
    model.η = η
    model.η_dirty = true;
end

function setZeta!(model::DiversinetModel, ζ::Float64)
    ζ < 0 && throw(DomainError("setZeta called with negative ζ."))
    model.ζ = ζ
    model.ζ_dirty = true;
end

function setNu!(model::DiversinetModel, ν::Float64)
    ν < 0 && throw(DomainError("setNu called with negative ν."))
    model.ν = ν
    model.ν_dirty = true;
end

function setPsi!(model::DiversinetModel, ψ::Float64)
    ψ < 0 && throw(DomainError("setPsi called with negative ψ."))
    model.ψ = ψ
    model.ψ_dirty = true;
end

function setRho!(model::DiversinetModel, ρ::Float64)
    ρ < 0 && throw(DomainError("setRho called with negative ρ."))
    ρ > 1 && throw(DomainError("setRho called with ρ greater than 1."))
    model.ρ = ρ
    model.ρ_dirty = true
end

function setKmax!(model::DiversinetModel, kmax::Int64)
    kmax < 1 && throw(DomainError("setKmax called with value less than 1."))
    model.kmax = kmax
    model.k_dirty = true
end

function setConditionalProbabilityType!(model::DiversinetModel, cond::Condition)
    model.cond = cond
    model.cond_dirty = true
end

function computeLikelihood!(model::DiversinetModel)

    # first, make sure the model is prepared
    prepareModel!(model)

    # now, compute the computeLikelihood
    lnl = DiversinetInterface.computeLogLikelihood(model.tp)
    
    # done
    return lnl

end

function prepareModel!(model::DiversinetModel)
    
    # check for parameter updates

    if model.λ_dirty
        DiversinetInterface.setLambda(model.tp, model.λ);
        model.λ_dirty = false;
    end

    if model.μ_dirty
        DiversinetInterface.setMu(model.tp, model.μ);
        model.μ_dirty = false;
    end

    if model.η_dirty
        DiversinetInterface.setEta(model.tp, model.η);
        model.η_dirty = false;
    end

    if model.ζ_dirty
        DiversinetInterface.setZeta(model.tp, model.ζ);
        model.ζ_dirty = false;
    end

    if model.ν_dirty
        DiversinetInterface.setNu(model.tp, model.ν);
        model.ν_dirty = false;
    end

    if model.ψ_dirty
        DiversinetInterface.setPsi(model.tp, model.ψ);
        model.ψ_dirty = false;
    end

    if model.ρ_dirty
        DiversinetInterface.setRho(model.tp, model.ρ);
        model.ρ_dirty = false;
    end

    if model.k_dirty
        DiversinetInterface.setKMaxInt(model.tp, model.kmax);
        model.k_dirty = false;
    end

    if model.cond_dirty
        DiversinetInterface.setConditionalProbabilityType(model.tp, Int64(model.cond));
        model.cond_dirty = false;
    end

end