module TransverseIsing1D

using ITensors

include("SpinHalf.jl")

export fromDict, getSites, getHamiltonian, getObservables, getGatesEven, getGatesOdd


function getDefaultParameters()::Dict{String,Any}
    return Dict{String,Any}(
        "L" => 16,
        "J" => 1.0,
        "hx" => 1.0,
        "hz" => 0.5,
        "pbc" => false,
    )
end

function getSites(parameters::Dict{String,Any})::Vector{Index{Int64}}
    sites = siteinds("S=1/2", parameters["L"])
    return sites
end

function getHamiltonian(sites::Vector{Index{Int64}}, parameters::Dict{String,Any})::MPO
    ampo = OpSum()

    L = parameters["L"]
    J = parameters["J"]
    hx = parameters["hx"]
    hz = parameters["hz"]

    for j = 1:L-1
        ampo += -4.0 * J, "Sz", j, "Sz", j + 1
    end

    if parameters["pbc"]
        ampo += -4.0 * J, "Sz", L, "Sz", 1
    end

    for j = 1:L
        ampo += -2.0 * hx, "Sx", j
    end

    for j = 1:L
        ampo += -2.0 * hz, "Sz", j
    end

    return MPO(ampo, sites)
end

function getObservables(sites::Vector{Index{Int64}}, parameters::Dict{String,Any})::Dict{String,MPO}
    return Dict(
        "H" => getHamiltonian(sites, parameters),
        "Sx" => getTotalSx(sites),
        "Sz" => getTotalSz(sites)
    )
end

function getLocalOperators()::Dict{String,Tuple{Float64,String}}
    return Dict(
        "Sx" => (2.0, "Sx"),
        "Sz" => (2.0, "Sz"),
    )
end

function getCorrelationFunctions()::Dict{String,Tuple{Float64,String,String}}
    return Dict(
        "SzSz" => (4.0, "Sz", "Sz"),
    )
end

function getGatesEven(sites::Vector{Index{Int64}}, dt::Float64, parameters::Dict{String,Any})::Vector{ITensor}
    if parameters["pbc"]
        throw(DomainError(parameters["pbc"], "not implemented for periodic boundary conditions"))
    end

    gates = Vector{ITensor}()

    L = parameters["L"]
    J = parameters["J"]
    hx = parameters["hx"]
    hz = parameters["hz"]

    for j = 2:2:L-1
        s1 = sites[j]
        s2 = sites[j+1]

        hj = -4.0 * J * op("Sz", s1) * op("Sz", s2)
        -2.0 * hx * op("Sx", s1)
        -2.0 * hz * op("Sz", s1)

        push!(gates, exp(-1.0im * dt * hj))
    end

    # if L % 2 == 0
    #     hj = -2.0 * hx * op("Sx", sites[L]) - 2.0 * hz * op("Sz", sites[L])
    #     push!(gates, exp(-1.0im * dt * hj))
    # end

    return gates
end

function getGatesOdd(sites::Vector{Index{Int64}}, dt::Float64, parameters::Dict{String,Any})::Vector{ITensor}
    if parameters["pbc"]
        throw(DomainError(parameters["pbc"], "not implemented for periodic boundary conditions"))
    end

    gates = Vector{ITensor}()

    L = parameters["L"]
    J = parameters["J"]
    hx = parameters["hx"]
    hz = parameters["hz"]

    for j = 1:2:L-1
        s1 = sites[j]
        s2 = sites[j+1]

        hj = -4.0 * J * op("Sz", s1) * op("Sz", s2)
        -2.0 * hx * op("Sx", s1)
        -2.0 * hz * op("Sz", s1)

        push!(gates, exp(-1.0im * dt * hj))
    end

    # if L % 2 == 1
    #     hj = -2.0 * hx * op("Sx", sites[L]) - 2.0 * hz * op("Sz", sites[L])
    #     push!(gates, exp(-1.0im * dt * hj))
    # end

    return gates
end


if Base.VERSION >= v"1.4.2"
    include("../Precompile/precompile_MPSTools.TransverseIsing1D.jl")
    _precompile_()
end

end