function _precompile_()
    ccall(:jl_generating_output, Cint, ()) == 1 || return nothing
    Base.precompile(Tuple{typeof(getHamiltonian),Vector{Index{Int64}},Dict{String, Any}})   # time: 0.19770716
    Base.precompile(Tuple{typeof(getObservables),Vector{Index{Int64}},Dict{String, Any}})   # time: 0.04009594
    Base.precompile(Tuple{typeof(getSites),Dict{String, Any}})   # time: 0.007832442
    Base.precompile(Tuple{typeof(getDefaultParameters)})   # time: 0.007691231
end
