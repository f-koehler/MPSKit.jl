mutable struct DMRGOptions
    num_states::Int64
    sweeps::Sweeps
    overlap_penalty::Float64
    quiet::Bool
end

mutable struct DMRGResults
    states::Vector{MPS}
    overlaps::Array{Float64,2}
    observables::Vector{Dict{String,Tuple{Float64,Float64,Float64}}}
    localOperators::Vector{Dict{String,Vector{Float64}}}
    correlationFunctions::Vector{Dict{String,Matrix{Float64}}}
end

function getDefaultSweeps()::Sweeps
    sweeps = Sweeps(8)
    setmaxdim!(sweeps, 50, 80, 100, 150, 200, 250, 300, 500)
    setmindim!(sweeps, 1, 1, 1, 1, 1, 1, 1, 1)
    setcutoff!(sweeps, 1e-6, 1e-8, 1e-10, 1e-12, 1e-12, 1e-12, 0.0, 0.0)
    setnoise!(sweeps, 1e-7, 1e-8, 1e-9, 1e-10, 1e-11, 1e-12, 0.0, 0.0)
    return sweeps
end

function storeDMRGResult(file::String, result::DMRGResults)
    fptr = HDF5.h5open(file, "w")

    # store states
    for (i, state) in enumerate(result.states)
        HDF5.write(fptr, "psi_" * string(i), state)
    end

    # store observables
    for (i, observables) in enumerate(result.observables)
        grp_state = HDF5.create_group(fptr, string("observables_", string(i)))
        for (name, values) in observables
            grp_observable = HDF5.create_group(grp_state, string(name))
            HDF5.write(grp_observable, "value", values[1])
            HDF5.write(grp_observable, "squared", values[2])
            HDF5.write(grp_observable, "variance", values[3])
        end
    end

    # store local operators
    for (i, localOperators) in enumerate(result.localOperators)
        grp_state = HDF5.create_group(fptr, string("local_operators_", string(i)))
        for (name, values) in localOperators
            write(grp_state, name, values)
        end
    end

    # store correlation functions operators
    for (i, correlationFunctions) in enumerate(result.correlationFunctions)
        grp_state = HDF5.create_group(fptr, string("correlation_functions_", string(i)))
        for (name, values) in correlationFunctions
            write(grp_state, name, values)
        end
    end

    # store overlaps
    HDF5.write(fptr, "overlaps", result.overlaps)

    HDF5.close(fptr)
end


function runDMRG(model::Module, parameters::Dict{String,Any}, options::DMRGOptions)::DMRGResults
    sites = model.getSites(parameters)
    hamiltonian = model.getHamiltonian(sites, parameters)
    psi0 = randomMPS(sites)

    results = DMRGResults(
        Vector{MPS}(),
        zeros(Float64, options.num_states, options.num_states),
        Vector{Dict{String,Tuple{Float64,Float64,Float64}}}(),
        Vector{Dict{String,Vector{Float64}}}(),
        Vector{Dict{String,Matrix{Float64}}}()
    )

    for j = 1:options.num_states
        if length(results.states) == 0
            _, psi = dmrg(hamiltonian, psi0, options.sweeps; outputlevel = options.quiet ? 0 : 1)
            push!(results.states, psi)
            psi0 = psi
        else
            _, psi = dmrg(hamiltonian, result.states, psi0, options.sweeps; options.overlap_penalty, outputlevel = options.quiet ? 0 : 1)
            push!(result.states, psi)
            psi0 = psi
        end
    end

    for (i, state) in enumerate(results.states)
        push!(results.observables, Dict{String,Tuple{Float64,Float64,Float64}}())
        for (name, operator) in model.getObservables(sites, parameters)
            value = inner(state, operator, state)
            squared = inner(operator, state, operator, state)
            variance = squared - (value^2)
            results.observables[i][name] = (value, squared, variance)
        end

        push!(results.localOperators, Dict{String,Vector{Float64}}())
        for (name, localOperator) in model.getLocalOperators()
            results.localOperators[i][name] = expect(state, localOperator[2]) * localOperator[1]
        end

        push!(results.correlationFunctions, Dict{String,Matrix{Float64}}())
        for (name, correlationFunction) in model.getCorrelationFunctions()
            results.correlationFunctions[i][name] = correlation_matrix(state, correlationFunction[2], correlationFunction[3]) * correlationFunction[1]
        end
    end

    for i = 1:options.num_states
        for j = 1:options.num_states
            results.overlaps[i, j] = inner(results.states[i], results.states[j])
        end
    end
    return results
end