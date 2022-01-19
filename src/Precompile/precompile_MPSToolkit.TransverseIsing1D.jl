function _precompile_()
    ccall(:jl_generating_output, Cint, ()) == 1 || return nothing
    Base.precompile(Tuple{typeof(getCorrelationFunctions)})   # time: 0.04985839
    Base.precompile(Tuple{typeof(getLocalOperators)})   # time: 0.04234978
end
