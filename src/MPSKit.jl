module MPSKit

using ITensors

include("DMRG.jl")
export DMRGOptions, DMRGResults, runDMRG, getDefaultSweeps

include("Models.jl")
export getModel

include("TEBD.jl")

if Base.VERSION >= v"1.4.2"
    include("Precompile/precompile_MPSKit.jl")
    _precompile_()
end

end