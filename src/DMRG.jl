using ArgParse
using TOML
using ITensors

include("Models/Models.jl")
using .Models


function sweepsFromTOML(toml::Vector{Dict{String,Any}})::Sweeps
    sweeps = Sweeps(length(toml))
    for (i, sweep) in enumerate(toml)
        sweeps.maxdim[i] = get(sweep, "maxdim", sweeps.maxdim[i])
        sweeps.mindim[i] = get(sweep, "mindim", sweeps.mindim[i])
        sweeps.cutoff[i] = get(sweep, "cutoff", sweeps.cutoff[i])
        sweeps.noise[i] = get(sweep, "noise", sweeps.noise[i])
    end
    return sweeps
end



function main(args::Vector{String})
    s = ArgParseSettings(description = "Compute ground states using DMRG.")
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

    sweeps = sweepsFromTOML(config["dmrg"]["sweeps"])
    _, psi = dmrg(hamiltonian, psi0, sweeps)

    for (name, operator) in model.getObservables(sites, parameters)
        value = inner(psi, operator, psi)
        squared = inner(operator, psi, operator, psi)
        variance = squared - (value^2)
        println(name, " = ", value, " ± ", variance)
    end
end

main(ARGS)