include("Models/TransverseIsing1D.jl")
using .TransverseIsing1D

function getModel(name::String)::Module
    if name == "TransverseIsing1D"
        return TransverseIsing1D
    end

    throw(DomainError(name, "Model not found"))
end