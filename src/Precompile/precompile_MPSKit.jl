function _precompile_()
    ccall(:jl_generating_output, Cint, ()) == 1 || return nothing
    Base.precompile(Tuple{typeof(runDMRG),Module,Dict{String, Any},DMRGOptions})   # time: 3.370874
    Base.precompile(Tuple{typeof(getDefaultSweeps)})   # time: 0.030399939
    Base.precompile(Tuple{typeof(disableThreading)})   # time: 0.001590108
end
