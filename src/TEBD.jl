export TEBDOptions, TEBDResults, storeTEBDResult, runTEBD

struct TEBDOptions
    order::Int64
    tfinal::Float64
    dt::Float64
    substeps::Int64
    cutoff::Float64
end

struct TEBDResults
    time::Vector{Float64}
    observables::Dict{String,Tuple{Vector{ComplexF64},Vector{ComplexF64},Vector{ComplexF64}}}
    localOperators::Dict{String,Vector{Vector{ComplexF64}}}
    correlationFunctions::Dict{String,Vector{Matrix{ComplexF64}}}
    maxBondDimension::Vector{Int64}
end

function buildGatesTEBD1(model::Model, dt::Float64)::Vector{ITensor}
    return vcat(getGatesEven(model, dt), getGatesOdd(model, dt))
end

function buildGatesTEBD2(model::Model, dt::Float64)::Vector{ITensor}
    even = getGatesEven(model, dt / 2.0)
    return vcat(even, getGatesOdd(model, dt), reverse(even))
end

function buildGatesTEBD3(model::Model, dt::Float64)::Vector{ITensor}
    s = 1.0 / (2.0 - (2.0^(1.0 / 3.0)))
    dt1 = s * dt
    dt2 = (1 - 2.0 * s) * dt
    return vcat(
        buildGatesTEBD2(model, dt1),
        buildGatesTEBD2(model, dt2),
        buildGatesTEBD2(model, dt1)
    )
end

function storeTEBDResult(file::String, result::TEBDResults)
    mkpath(dirname(file))
    fptr = HDF5.h5open(file, "w")

    HDF5.write(fptr, "time", result.time)

    grp_observables = HDF5.create_group(fptr, "observables")
    for (name, values) in result.observables
        grp_observable = HDF5.create_group(grp_observables, string(name))
        HDF5.write(grp_observable, "value", values[1])
        HDF5.write(grp_observable, "squared", values[2])
        HDF5.write(grp_observable, "variance", values[3])
    end

    grpLocalOperators = HDF5.create_group(fptr, "local_operators")
    for (name, values) in result.localOperators
        HDF5.write(grpLocalOperators, name, reduce(hcat, values))
    end

    grpCorrelationFunctions = HDF5.create_group(fptr, "correlation_functions")
    for (name, values) in result.correlationFunctions
        # FIXME: there should be definitely a clever way to do this using reduce, hcat and reshape
        mat = Array{ComplexF64,3}(undef, size(values[1])[1], size(values[1])[1], length(result.time))
        for (i, _) in enumerate(result.time)
            mat[:, :, i] = values[i]
        end
        HDF5.write(grpCorrelationFunctions, name, mat)
    end

    HDF5.write(fptr, "max_bond_dimension", result.maxBondDimension)

    HDF5.close(fptr)
end

function runTEBD(psi0::MPS, model::Model, options::TEBDOptions)::TEBDResults
    sites = model.sites

    step = options.dt / options.substeps
    @info "Set substep size for TEBD to $step"

    @info "Construct TEBD gates …"
    gates = ITensor[]
    if options.order == 1
        gates = buildGatesTEBD1(model, step)
    elseif options.order == 2
        gates = buildGatesTEBD2(model, step)
    elseif options.order == 3
        gates = buildGatesTEBD3(model, step)
    else
        throw(DomainError(order, "TEBD not implemented for specified order"))
    end
    num_gates = length(gates)
    @info "Constructed $num_gates gates"

    gates = repeat(gates, options.substeps)

    time = 0.0
    psi = deepcopy(psi0)
    results = TEBDResults(
        Float64[],
        Dict{String,Tuple{Vector{ComplexF64},Vector{ComplexF64},Vector{ComplexF64}}}(),
        Dict{String,Vector{Vector{ComplexF64}}}(),
        Dict{String,Vector{Matrix{ComplexF64}}}(),
        Int64[]
    )

    push!(results.time, time)

    # measure initial observables
    for observable in getObservables(model)
        results.observables[observable.name] = (ComplexF64[], ComplexF64[], ComplexF64[])
        values = expect(psi, observable)
        push!(results.observables[observable.name][1], values[1])
        push!(results.observables[observable.name][2], values[2])
        push!(results.observables[observable.name][3], values[3])
        push!(results.maxBondDimension, maxlinkdim(psi))
    end

    # measure initial local operators
    for localOperator in getLocalOperators(model)
        results.localOperators[localOperator.name] = Vector{ComplexF64}[]
        push!(results.localOperators[localOperator.name], expect(psi, localOperator))
    end

    # measure initial correlation functions
    for correlationFunction in getCorrelationFunctions(model)
        results.correlationFunctions[correlationFunction.name] = Matrix{ComplexF64}[]
        push!(results.correlationFunctions[correlationFunction.name], expect(psi, correlationFunction))
    end

    maxBondDimension = 0

    while time < options.tfinal
        psi = apply(gates, psi; cutoff = options.cutoff)
        time += options.dt
        push!(results.time, time)
        push!(results.maxBondDimension, maxBondDimension)

        # measure current observables
        for observable in getObservables(model)
            values = expect(psi, observable)
            push!(results.observables[observable.name][1], values[1])
            push!(results.observables[observable.name][2], values[2])
            push!(results.observables[observable.name][3], values[3])
            maxBondDimension = maxlinkdim(psi)
        end

        # measure initial local operators
        for localOperator in getLocalOperators(model)
            push!(results.localOperators[localOperator.name], expect(psi, localOperator))
        end

        # measure initial correlation functions
        for correlationFunction in getCorrelationFunctions(model)
            push!(results.correlationFunctions[correlationFunction.name], expect(psi, correlationFunction))
        end

        percentage = time / options.tfinal * 100.0

        timestamp = Dates.format(now(), "YYYY-mm-dd HH:MM:SS")

        @info "$timestamp: Finished time=$time ($percentage%)"
        @info "                     max bond dimension=$maxBondDimension"
    end

    return results
end