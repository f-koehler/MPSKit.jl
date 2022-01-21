struct LocalOperator
    name::String
    prefactor::Float64
    op::String
end

struct CorrelationFunction
    name::String
    prefactor::Float64
    op1::String
    op2::String
end

struct Observable
    name::String
    op::MPO
end

function expect(psi::MPS, x::LocalOperator)::Vector{ComplexF64}
    return x.prefactor * ITensors.expect(psi, x.op)
end

function expect(psi::MPS, x::CorrelationFunction)::Matrix{ComplexF64}
    return x.prefactor * correlation_matrix(psi, x.op1, x.op2)
end

function expect(psi::MPS, x::Observable)::Tuple{ComplexF64,ComplexF64,ComplexF64}
    value = inner(psi, x.op, psi)
    squared = inner(x.op, psi, x.op, psi)
    variance = squared - (value^2)
    return value, squared, variance
end