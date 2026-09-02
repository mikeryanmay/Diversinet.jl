module DiversinetInterface

export computeLogLikelihood, jitterNewick, readNewick, setConditionalProbabilityType, setEta, setKMaxInt, setLambda
export setIntegrationScheme, setMu, setNu, setPsi, setRho, setZeta, simulate, simulate_many

using CxxWrap
import Diversinet_jll

@wrapmodule(() -> Diversinet_jll.libjlDiversinetInterface)

function __init__()
    @initcxx
end

end # module
