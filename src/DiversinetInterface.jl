module DiversinetInterface

export computeLogLikelihood, jitterNewick, readNewick, setConditionalProbabilityType, setEta, setKMaxInt, setLambda
export setIntegrationScheme, setMu, setNu, setPsi, setRho, setZeta, simulate, simulate_many

using CxxWrap
import Libdl

const _deps_file = joinpath(dirname(@__DIR__), "deps", "deps.jl")

isfile(_deps_file) ||
    error("Diversinet native interface is not configured. Run `import Pkg; Pkg.build(\"Diversinet\")`.")

include(_deps_file)

if diversinet_interface_uses_jll
    import Diversinet_jll
end

function _library_path()
    if isfile(diversinet_interface_lib)
        return diversinet_interface_lib
    end

    error("Could not find libjlDiversinetInterface at $(diversinet_interface_lib). Run `import Pkg; Pkg.build(\"Diversinet\")`.")
end

@wrapmodule(_library_path)

function __init__()
    @initcxx
end

end # module
