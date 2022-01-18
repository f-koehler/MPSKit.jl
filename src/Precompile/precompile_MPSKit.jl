function _precompile_()
    ccall(:jl_generating_output, Cint, ()) == 1 || return nothing
    Base.precompile(Tuple{typeof(runDMRG),Module,Dict{String, Any},DMRGOptions})   # time: 3.3157735
    Base.precompile(Tuple{typeof(getDefaultSweeps)})   # time: 0.018499458
    Base.precompile(Tuple{typeof(disableThreading)})   # time: 0.01255362
end
