mutable struct DMRGOptions
    num_states::Int64
    sweeps::Sweeps
    overlap_penalty::Float64
end

mutable struct DMRGResults
    states::Vector{MPS}
    overlaps::Array{Float64,2}
    observables::Vector{Dict{String,Tuple{Float64,Float64,Float64}}}
end

function getDefaultSweeps()::Sweeps
    sweeps = Sweeps(8)
    setmaxdim!(sweeps, 50, 80, 100, 150, 200, 250, 300, 500)
    setmindim!(sweeps, 1, 1, 1, 1, 1, 1, 1, 1)
    setcutoff!(sweeps, 1e-6, 1e-8, 1e-10, 1e-12, 1e-12, 1e-12, 0.0, 0.0)
    setnoise!(sweeps, 1e-7, 1e-8, 1e-9, 1e-10, 1e-11, 1e-12, 0.0, 0.0)
    return sweeps
end


function runDMRG(model::Module, parameters::Dict{String,Any}, options::DMRGOptions)::DMRGResults
    sites = model.getSites(parameters)
    hamiltonian = model.getHamiltonian(sites, parameters)
    psi0 = randomMPS(sites)

    results = DMRGResults(
        Vector{MPS}(),
        zeros(Float64, options.num_states, options.num_states),
        Vector{Dict{String,Tuple{Float64,Float64,Float64}}}()
    )

    for j = 1:options.num_states
        if length(results.states) == 0
            _, psi = dmrg(hamiltonian, psi0, options.sweeps)
            push!(results.states, psi)
            psi0 = psi
        else
            _, psi = dmrg(hamiltonian, result.states, psi0, options.sweeps; options.overlap_penalty)
            push!(result.states, psi)
            psi0 = psi
        end
    end

    for (i, state) in enumerate(results.states)
        for (name, operator) in model.getObservables(sites, parameters)
            value = inner(state, operator, state)
            squared = inner(operator, state, operator, state)
            variance = squared - (value^2)
            #         # results.observables[i][name] = (value)
        end
    end

    # for i = 1:length(states)
    #     for j = 1:i
    #         println("<psi_", i, "|psi_", j, "> = ", inner(states[i], states[j]))
    #     end
    # end
    return results
end