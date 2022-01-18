function _precompile_()
    ccall(:jl_generating_output, Cint, ()) == 1 || return nothing
    Base.precompile(Tuple{typeof(getLocalOperators)})   # time: 0.037843514
    Base.precompile(Tuple{typeof(getCorrelationFunctions)})   # time: 0.03019474
end
