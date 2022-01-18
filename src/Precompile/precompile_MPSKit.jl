function _precompile_()
    ccall(:jl_generating_output, Cint, ()) == 1 || return nothing
    Base.precompile(Tuple{typeof(runDMRG),Module,Dict{String, Any},DMRGOptions})   # time: 11.108759
    Base.precompile(Tuple{typeof(getDefaultSweeps)})   # time: 0.020593848
end
