export TransverseIsing1D, getHamiltonian, getObservables, getLocalOperators, getCorrelationFunctions, getGatesEven, getGatesOdd

struct TransverseIsing1D <: SpinHalf
    parameters::Dict{String,Any}
    sites::Vector{Index{Int64}}

    TransverseIsing1D(L::Int64) = new(
        Dict{String,Any}(
            "L" => L,
            "J" => 1.0,
            "hx" => 1.0,
            "hz" => 0.5,
            "pbc" => false,
        ),
        siteinds("S=1/2", L)
    )
end

function getHamiltonian(model::TransverseIsing1D)::MPO
    ampo = OpSum()

    L = model.parameters["L"]
    J = model.parameters["J"]
    hx = model.parameters["hx"]
    hz = model.parameters["hz"]

    for j = 1:L-1
        ampo += -4.0 * J, "Sz", j, "Sz", j + 1
    end

    if model.parameters["pbc"]
        ampo += -4.0 * J, "Sz", L, "Sz", 1
    end

    for j = 1:L
        ampo += -2.0 * hx, "Sx", j
    end

    for j = 1:L
        ampo += -2.0 * hz, "Sz", j
    end

    return MPO(ampo, model.sites)
end

function getObservables(model::TransverseIsing1D)::Vector{Observable}
    return [
        Observable("H", getHamiltonian(model)),
        Observable("Sx", getTotalSx(model)),
        Observable("Sz", getTotalSz(model))
    ]
end

function getLocalOperators(model::TransverseIsing1D)::Vector{LocalOperator}
    return [
        LocalOperator("sx", 2.0, "Sx"),
        LocalOperator("sz", 2.0, "Sz"),
    ]
end

function getCorrelationFunctions(model::TransverseIsing1D)::Vector{CorrelationFunction}
    return [
        CorrelationFunction("sz_sz", 4.0, "Sz", "Sz"),
    ]
end

function getGatesEven(model::TransverseIsing1D, dt::Float64)::Vector{ITensor}
    if model.parameters["pbc"]
        throw(DomainError(model.parameters["pbc"], "not implemented for periodic boundary conditions"))
    end

    gates = ITensor[]

    L = model.parameters["L"]
    J = model.parameters["J"]
    hx = model.parameters["hx"]
    hz = model.parameters["hz"]

    for j = 2:2:L-1
        s1 = model.sites[j]
        s2 = model.sites[j+1]

        hj = -4.0 * J * op("Sz", s1) * op("Sz", s2)
        hj -= 2.0 * hx * op("Sx", s1) * op("Id", s2)
        hj -= 2.0 * hz * op("Sz", s1) * op("Id", s2)

        push!(gates, exp(-1.0im * dt * hj))
    end

    if L % 2 == 0
        hj = -2.0 * hx * op("Sx", model.sites[L])
        hj -= 2.0 * hz * op("Sz", model.sites[L])
        push!(gates, exp(-1.0im * dt * hj))
    end

    return gates
end

function getGatesOdd(model::TransverseIsing1D, dt::Float64)::Vector{ITensor}
    if model.parameters["pbc"]
        throw(DomainError(model.parameters["pbc"], "not implemented for periodic boundary conditions"))
    end

    gates = ITensor[]

    L = model.parameters["L"]
    J = model.parameters["J"]
    hx = model.parameters["hx"]
    hz = model.parameters["hz"]

    for j = 1:2:L-1
        s1 = model.sites[j]
        s2 = model.sites[j+1]

        hj = -4.0 * J * op("Sz", s1) * op("Sz", s2)
        hj -= 2.0 * hx * op("Sx", s1) * op("Id", s2)
        hj -= 2.0 * hz * op("Sz", s1) * op("Id", s2)

        push!(gates, exp(-1.0im * dt * hj))
    end

    if L % 2 == 1
        hj = -2.0 * hx * op("Sx", model.sites[L])
        hj -= 2.0 * hz * op("Sz", model.sites[L])
        push!(gates, exp(-1.0im * dt * hj))
    end

    return gates
end