function computeKmax(nsamples::Int64, ρ::Float64, q::Float64 = 0.99)
    
    # initialize the negative binomial dist
    nb = Distributions.NegativeBinomial(nsamples, ρ)

    # get the quantile
    return Distributions.quantile(nb, q) + 1
    
end;