module DMRG

export runDMRG

using ArgParse
using TOML
using ITensors

include("Models/Models.jl")
using .Models


function getSweepsFromTOML(toml::Vector{Dict{String,Any}})::Sweeps
    sweeps = Sweeps(length(toml))
    for (i, sweep) in enumerate(toml)
        sweeps.maxdim[i] = get(sweep, "maxdim", sweeps.maxdim[i])
        sweeps.mindim[i] = get(sweep, "mindim", sweeps.mindim[i])
        sweeps.cutoff[i] = get(sweep, "cutoff", sweeps.cutoff[i])
        sweeps.noise[i] = get(sweep, "noise", sweeps.noise[i])
    end
    return sweeps
end



function runDMRG(args::Vector{String})
    s = ArgParseSettings(description = "Compute eigenstates using DMRG.")
    @add_arg_table! s begin
        "-i", "--input"
        arg_type = String
    end

    parsed_args = parse_args(args, s)
    config = TOML.parsefile(parsed_args["input"])

    model = Models.getModel(config["model"]["name"])

    parameters = model.fromTOML(config["model"])
    sites = model.getSites(parameters)
    hamiltonian = model.getHamiltonian(sites, parameters)
    psi0 = randomMPS(sites)

    sweeps = getSweepsFromTOML(config["dmrg"]["sweeps"])
    num_states = get(config["dmrg"], "states", 1)
    overlap_penalty = get(config["dmrg"], "overlap_penalty", 10)

    states = MPS[]
    for j = 1:num_states
        if length(states) == 0
            _, psi = dmrg(hamiltonian, psi0, sweeps)
            push!(states, psi)
            psi0 = psi
        else
            _, psi = dmrg(hamiltonian, states, psi0, sweeps; overlap_penalty)
            push!(states, psi)
            psi0 = psi
        end
    end

    for (i, state) in enumerate(states)
        print(i, ":")
        for (name, operator) in model.getObservables(sites, parameters)
            value = inner(state, operator, state)
            squared = inner(operator, state, operator, state)
            variance = squared - (value^2)
            println("\t", name, " = ", value, " ± ", variance)
        end
    end

    for i = 1:length(states)
        for j = 1:i
            println("<psi_", i, "|psi_", j, "> = ", inner(states[i], states[j]))
        end
    end
end

end