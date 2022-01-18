function _precompile_()
    ccall(:jl_generating_output, Cint, ()) == 1 || return nothing
    Base.precompile(Tuple{typeof(runDMRG),Module,Dict{String, Any},DMRGOptions})   # time: 3.570115
    Base.precompile(Tuple{typeof(getDefaultSweeps)})   # time: 0.020822993
end
