module TransverseIsing1D

using ITensors

include("SpinHalf.jl")

export Parameters, fromTOML, getSites, getHamiltonian, getObservables, getGatesEven, getGatesOdd

mutable struct Parameters
    L::Int64
    J::Float64
    hx::Float64
    hz::Float64
    pbc::Bool
end

function fromTOML(toml::Dict{String,Any})::Parameters
    return Parameters(
        get(toml, "L", 16),
        get(toml, "J", 1.0),
        get(toml, "hx", 1.0),
        get(toml, "hz", 0.5),
        get(toml, "pbc", false)
    )
end

function getSites(parameters::Parameters)::Vector{Index{Int64}}
    sites = siteinds("S=1/2", parameters.L)
    return sites
end

function getHamiltonian(sites::Vector{Index{Int64}}, parameters::Parameters)::MPO
    ampo = OpSum()

    for j = 1:parameters.L-1
        ampo += -4.0 * parameters.J, "Sz", j, "Sz", j + 1
    end

    if parameters.pbc
        ampo += -4.0 * parameters.J, "Sz", j, "Sz", j + 1
    end

    for j = 1:parameters.L
        ampo += -2.0 * parameters.hx, "Sx", j
    end

    for j = 1:parameters.L
        ampo += -2.0 * parameters.hz, "Sz", j
    end

    return MPO(ampo, sites)
end

function getObservables(sites::Vector{Index{Int64}}, parameters::Parameters)::Dict{String,MPO}
    return Dict(
        "H" => getHamiltonian(sites, parameters),
        "Sx" => getTotalSx(sites),
        "Sz" => getTotalSz(sites)
    )
end

function getGatesEven(sites::Vector{Index{Int64}}, dt::Float64, parameters::Parameters)::ITensor[]
    if parameters.pbc
        throw(DomainError(parameters.pbc, "not implemented for periodic boundary conditions"))
    end

    gates = ITensor[]

    for j = 2:2:parameters.L-1
        s1 = sites[j]
        s2 = sites[j+1]

        hj = -4.0 * parameters.J * op("Sz", s1) * op("Sz", s2)
        -2.0 * parameters.hx * op("Sx", s1)
        -2.0 * parameters.hz * op("Sz", s1)

        push!(gates, exp(-1.0im * dt * hj))
    end

    if L % 2 == 0
        hj = -2.0 * parameters.hx * op("Sx", sites[parameters.L]) - 2.0 * parameters.hz * op("Sz", sites[parameters.L])
        push!(gates, exp(-1.0im * dt * hj))
    end

    return gates
end

function getGatesOdd(sites::Vector{Index{Int64}}, dt::Float64, parameters::Parameters)::ITensor[]
    if parameters.pbc
        throw(DomainError(parameters.pbc, "not implemented for periodic boundary conditions"))
    end

    gates = ITensor[]

    for j = 1:2:parameters.L-1
        s1 = sites[j]
        s2 = sites[j+1]

        hj = -4.0 * parameters.J * op("Sz", s1) * op("Sz", s2)
        -2.0 * parameters.hx * op("Sx", s1)
        -2.0 * parameters.hz * op("Sz", s1)

        push!(gates, exp(-1.0im * dt * hj))
    end

    if L % 2 == 1
        hj = -2.0 * parameters.hx * op("Sx", sites[parameters.L]) - 2.0 * parameters.hz * op("Sz", sites[parameters.L])
        push!(gates, exp(-1.0im * dt * hj))
    end

    return gates
end

end