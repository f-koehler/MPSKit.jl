module MPSToolkit

using Logging
using LinearAlgebra
import ITensors.HDF5
import ITensors.Strided

using ITensors
export setmaxdim!, setmindim!, setcutoff!, setnoise!, Sweeps

include("Observables.jl")
include("Models/Model.jl")
include("Models/SpinHalf.jl")
include("Models/TransverseIsing1D.jl")
include("DMRG.jl")
include("TEBD.jl")
include("Util.jl")

export DMRGOptions, DMRGResults, runDMRG, getDefaultSweeps, storeDMRGResult
export getGatesEven, getGatesOdd
export TransverseIsing1D
export runTEBD, TEBDOptions, TEBDResults, storeTEBDResult
export disableThreading

if Base.VERSION >= v"1.4.2"
    include("Precompile/precompile_MPSToolkit.jl")
    _precompile_()
end

end