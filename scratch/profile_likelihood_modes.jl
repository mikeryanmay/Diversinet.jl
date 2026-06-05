using Pkg
Pkg.activate(joinpath(@__DIR__, ".."))

using Diversinet
using Profile

const LARGE_NEWICK_FILE = joinpath(@__DIR__, "test_net.tre")

function usage()
    println("""
    Usage:
      julia --project=. scratch/profile_likelihood_modes.jl [--small] [--large] [--n N] [--profile-n N] [--kmax K]

    Compares repeated likelihood calls through:
      fresh    Diversinet.computeLogLikelihood(newick; ...)
      retained DiversinetModel(newick; ...), setters, computeLikelihood!(model)
    """)
end

function parse_cli(args)
    opts = Dict{Symbol,Any}(
        :network => :large,
        :n => 50,
        :profile_n => 20,
        :kmax => 64,
    )

    i = 1
    while i <= length(args)
        arg = args[i]
        if arg == "--help" || arg == "-h"
            usage()
            exit()
        elseif arg == "--small"
            opts[:network] = :small
        elseif arg == "--large"
            opts[:network] = :large
        elseif arg == "--n"
            i += 1
            opts[:n] = parse(Int, args[i])
        elseif arg == "--profile-n"
            i += 1
            opts[:profile_n] = parse(Int, args[i])
        elseif arg == "--kmax"
            i += 1
            opts[:kmax] = parse(Int, args[i])
        else
            error("Unknown argument: $arg")
        end
        i += 1
    end

    return opts
end

function load_newick(which::Symbol)
    if which == :small
        return "((A:0.5,B:0.5):0.25,C:0.75):0.25;"
    elseif which == :large
        return String(strip(read(LARGE_NEWICK_FILE, String)))
    end
    error("Unknown network choice: $which")
end

function parameter_grid(n)
    lambdas = range(0.45, 1.55; length = n)
    epsilons = range(0.04, 0.22; length = n)
    psis = range(0.0005, 0.012; length = n)
    return collect(zip(lambdas, epsilons, psis))
end

function fresh_lls(newick, params; rho, kmax)
    out = Vector{Float64}(undef, length(params))
    for (i, (lambda, epsilon, psi)) in pairs(params)
        mu = epsilon * lambda
        out[i] = Diversinet.computeLogLikelihood(newick; λ = lambda, μ = mu, ψ = psi, ρ = rho, kmax = kmax)
    end
    return out
end

function retained_lls(newick, params; rho, kmax, skip_unchanged = false, rebuild_approximator = false)
    model = Diversinet.DiversinetModel(newick; λ = 1.0, μ = 0.0, ψ = 0.0, ρ = rho, kmax = kmax)
    last = [1.0, 0.0, 0.0]
    out = Vector{Float64}(undef, length(params))

    for (i, (lambda, epsilon, psi)) in pairs(params)
        mu = epsilon * lambda

        if !skip_unchanged || lambda != last[1]
            Diversinet.setLambda!(model, lambda)
            last[1] = lambda
        end
        if !skip_unchanged || mu != last[2]
            Diversinet.setMu!(model, mu)
            last[2] = mu
        end
        if !skip_unchanged || psi != last[3]
            Diversinet.setPsi!(model, psi)
            last[3] = psi
        end

        if rebuild_approximator
            Diversinet.setConditionalProbabilityType!(model, Diversinet.Nothing)
        end

        out[i] = Diversinet.computeLikelihood!(model)
    end

    finalize(model)
    return out
end

function time_call(label, f)
    GC.gc()
    result = @timed f()
    println(rpad(label, 24), " time = ", round(result.time; digits = 6),
            "s  alloc = ", round(result.bytes / 1024^2; digits = 3), " MiB",
            "  gc = ", round(result.gctime; digits = 6), "s")
    return result.value
end

function profile_call(label, f)
    GC.gc()
    Profile.clear()
    @profile f()
    println("\nProfile for $label")
    Profile.print(format = :flat, sortedby = :count, maxdepth = 30, noisefloor = 2.0)
end

function main(args)
    opts = parse_cli(args)
    newick = load_newick(opts[:network])
    params = parameter_grid(opts[:n])
    profile_params = params[1:min(opts[:profile_n], length(params))]
    rho = 0.5
    kmax = opts[:kmax]

    println("Network: ", opts[:network], "  chars: ", length(newick), "  calls: ", length(params), "  kmax: ", kmax)

    println("\nWarmup")
    fresh_lls(newick, params[1:2]; rho = rho, kmax = kmax)
    retained_lls(newick, params[1:2]; rho = rho, kmax = kmax)
    retained_lls(newick, params[1:2]; rho = rho, kmax = kmax, skip_unchanged = true)

    println("\nTiming")
    fresh = time_call("fresh", () -> fresh_lls(newick, params; rho = rho, kmax = kmax))
    retained = time_call("retained", () -> retained_lls(newick, params; rho = rho, kmax = kmax))
    retained_skip = time_call("retained skip-same", () -> retained_lls(newick, params; rho = rho, kmax = kmax, skip_unchanged = true))
    retained_rebuild = time_call("retained rebuild approx", () -> retained_lls(newick, params; rho = rho, kmax = kmax, rebuild_approximator = true))

    maxdiff = maximum(abs.(fresh .- retained))
    maxdiff_skip = maximum(abs.(fresh .- retained_skip))
    maxdiff_rebuild = maximum(abs.(fresh .- retained_rebuild))
    println("\nMax abs diff fresh vs retained: ", maxdiff)
    println("Max abs diff fresh vs retained skip-same: ", maxdiff_skip)
    println("Max abs diff fresh vs retained rebuild approx: ", maxdiff_rebuild)

    println("\nProfiling with ", length(profile_params), " calls per mode")
    profile_call("fresh", () -> fresh_lls(newick, profile_params; rho = rho, kmax = kmax))
    profile_call("retained", () -> retained_lls(newick, profile_params; rho = rho, kmax = kmax))
    profile_call("retained skip-same", () -> retained_lls(newick, profile_params; rho = rho, kmax = kmax, skip_unchanged = true))
    profile_call("retained rebuild approx", () -> retained_lls(newick, profile_params; rho = rho, kmax = kmax, rebuild_approximator = true))
end

main(ARGS)
