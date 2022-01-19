function _precompile_()
    ccall(:jl_generating_output, Cint, ()) == 1 || return nothing
    Base.precompile(Tuple{typeof(runDMRG),Module,Dict{String, Any},DMRGOptions})   # time: 4.080723
    Base.precompile(Tuple{typeof(getDefaultSweeps)})   # time: 0.035546243
    Base.precompile(Tuple{typeof(disableThreading)})   # time: 0.002017664
end
