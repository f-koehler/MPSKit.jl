module TEBD

using ITensors

function createTEBD1(dt::Float64, parameters, fEven::Function, fOdd::Function)::ITensor[]
    return vcat(fEven(dt, parameters), fOdd(dt, parameters))
end

function createTEBD2(dt::Float64, parameters, fEven::Function, fOdd::Function)::ITensor[]
    even = fEven(dt / 2, parameters)
    return vcat(even, fOdd(dt, parameters), reverse(even))
end

end