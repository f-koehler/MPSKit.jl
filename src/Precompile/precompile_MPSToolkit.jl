function _precompile_()
    ccall(:jl_generating_output, Cint, ()) == 1 || return nothing
    Base.precompile(Tuple{typeof(runTEBD),MPS,Module,Dict{String, Any},TEBDOptions})   # time: 1.6663153
    Base.precompile(Tuple{typeof(storeDMRGResult),String,DMRGResults})   # time: 0.26897237
end
