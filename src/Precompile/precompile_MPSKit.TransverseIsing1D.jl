function _precompile_()
    ccall(:jl_generating_output, Cint, ()) == 1 || return nothing
    Base.precompile(Tuple{typeof(getHamiltonian),Vector{Index{Int64}},Dict{String, Any}})   # time: 1.1434693
    Base.precompile(Tuple{typeof(getDefaultParameters)})   # time: 0.06976047
    Base.precompile(Tuple{typeof(getObservables),Vector{Index{Int64}},Dict{String, Any}})   # time: 0.055360455
    Base.precompile(Tuple{typeof(getSites),Dict{String, Any}})   # time: 0.009272495
end
