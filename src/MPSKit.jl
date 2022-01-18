module MPSKit

using ITensors
using LinearAlgebra
import ITensors.HDF5
import ITensors.Strided

include("DMRG.jl")
export DMRGOptions, DMRGResults, runDMRG, getDefaultSweeps, storeDMRGResult

include("Models.jl")
export getModel

include("TEBD.jl")

include("Util.jl")
export disableThreading

if Base.VERSION >= v"1.4.2"
    include("Precompile/precompile_MPSKit.jl")
    _precompile_()
end

end