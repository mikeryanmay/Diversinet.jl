function computeLogLikelihood(newick::String;
                              λ::Float64  = 1.0,
                              μ::Float64  = 0.0,
                              η::Float64  = 0.0,
                              ζ::Float64  = 0.0,
                              ν::Float64  = 0.0,
                              ψ::Float64  = 0.0,
                              ρ::Float64  = 1.0,
                              kmax::Int64 = 128
)

    # check bounds
    if λ < 0.0  return -Inf end
    if μ < 0.0  return -Inf end
    if η < 0.0  return -Inf end
    if ζ < 0.0  return -Inf end
    if ν < 0.0  return -Inf end
    if ψ < 0.0  return -Inf end
    if ρ <= 0.0 return -Inf end
    if ρ > 1.0  return -Inf end

    if isnan(λ) return -Inf end
    if isnan(μ) return -Inf end
    if isnan(η) return -Inf end
    if isnan(ζ) return -Inf end
    if isnan(ν) return -Inf end
    if isnan(ψ) return -Inf end
    if isnan(ρ) return -Inf end

    # make the model
    model = DiversinetModel(newick, λ = λ, μ = μ, η = η, ζ = ζ, ν = ν, ψ = ψ, ρ = ρ, kmax = kmax);

    # compute the likelihood
    lnl = computeLikelihood!(model)

    # # remove the model and force garbage collection (frees memory on c++ side)
    finalize(model)

    return lnl;

end