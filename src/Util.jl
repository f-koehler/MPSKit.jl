function disableThreading()
    Strided.disable_threads()
    ITensors.disable_threaded_blocksparse()
    BLAS.set_num_threads(1)
end

function computeExpectationValue(op::MPO, psi::MPS; hermitian = true)::Union{Tuple{Float64,Float64,Float64},Tuple{ComplexF64,ComplexF64,ComplexF64}}
    value = inner(psi, op, psi)
    squared = inner(op, psi, op, psi)
    variance = squared - (value^2)
    if hermitian
        if !isapprox(imag(value), 0.0; atol = 1e-12)
            throw(DomainError(value, "Detected large imaginary part in value"))
        end
        if !isapprox(imag(squared), 0.0; atol = 1e-12)
            throw(DomainError(squared, "Detected large imaginary part in squared"))
        end

        return real(value), real(squared), real(variance)
    end
    return value, squared, variance
end