struct TEBDOptions
    order::Int64
    tfinal::Float64
    dt::Float64
    substeps::Int64
    cutoff::Float64
end

struct TEBDResults
    time::Vector{Float64}
    observables::Dict{String,Tuple{Vector{Float64},Vector{Float64},Vector{Float64}}}
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
    fptr = HDF5.h5open(file, "w")
    grp_observables = HDF5.create_group(fptr, "observables")
    for (name, values) in result.observables
        grp_observable = HDF5.create_group(grp_observables, string(name))
        HDF5.write(grp_observable, "value", values[1])
        HDF5.write(grp_observable, "squared", values[2])
        HDF5.write(grp_observable, "variance", values[3])
    end
    HDF5.close(fptr)
end

function runTEBD(psi0::MPS, model::Model, options::TEBDOptions)::TEBDResults
    sites = model.sites

    step = options.dt / options.substeps

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

    time = 0.0
    psi = psi0
    results = TEBDResults(
        Vector{Float64}(),
        Dict{String,Tuple{Vector{Float64},Vector{Float64},Vector{Float64}}}()
    )

    push!(results.time, time)

    # measure initial observables
    for (name, operator) in getObservables(model)
        results.observables[name] = (Vector{Float64}(), Vector{Float64}(), Vector{Float64}())
        values = computeExpectationValue(operator, psi)
        push!(results.observables[name][1], values[1])
        push!(results.observables[name][2], values[2])
        push!(results.observables[name][3], values[3])
    end

    while time < options.tfinal
        for step = 1:options.substeps
            psi = apply(gates, psi; cutoff = options.cutoff)
        end
        time += options.dt
        push!(results.time, time)

        # measure current observables
        for (name, operator) in getObservables(model)
            values = computeExpectationValue(operator, psi)
            push!(results.observables[name][1], values[1])
            push!(results.observables[name][2], values[2])
            push!(results.observables[name][3], values[3])
        end

        percentage = time / options.tfinal * 100.0

        @info "Finished time=$time ($percentage%)"
    end

    return results
end