function _precompile_()
    ccall(:jl_generating_output, Cint, ()) == 1 || return nothing
    Base.precompile(Tuple{typeof(getHamiltonian),Vector{Index{Int64}},Dict{String, Any}})   # time: 0.22751758
    Base.precompile(Tuple{typeof(getObservables),Vector{Index{Int64}},Dict{String, Any}})   # time: 0.040284473
    Base.precompile(Tuple{typeof(getDefaultParameters)})   # time: 0.009971177
    Base.precompile(Tuple{typeof(getSites),Dict{String, Any}})   # time: 0.009817255
end
