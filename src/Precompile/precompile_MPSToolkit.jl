function _precompile_()
    ccall(:jl_generating_output, Cint, ()) == 1 || return nothing
    Base.precompile(Tuple{typeof(storeDMRGResult),String,DMRGResults})   # time: 0.20109193
    Base.precompile(Tuple{typeof(storeTEBDResult),String,TEBDResults})   # time: 0.012782501
end
