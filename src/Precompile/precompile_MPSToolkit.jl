function _precompile_()
    ccall(:jl_generating_output, Cint, ()) == 1 || return nothing
    Base.precompile(Tuple{typeof(runDMRG),TransverseIsing1D,DMRGOptions})   # time: 1.7270957
    Base.precompile(Tuple{typeof(runTEBD),MPS,TransverseIsing1D,TEBDOptions})   # time: 1.0837682
    Base.precompile(Tuple{typeof(getDefaultSweeps)})   # time: 0.026537951
    Base.precompile(Tuple{Type{TransverseIsing1D},Int64})   # time: 0.006096512
    Base.precompile(Tuple{typeof(disableThreading)})   # time: 0.001576538
end
