mutable struct TEBDOptions
    order::Int64
    tfinal::Float64
    dt::Float64
    substeps::Int64
    cutoff::Float64
end

function runTEBD(psi0::MPS, model::Module, parameters::Dict{String,Any}, options::TEBDOptions)
    sites = model.getSites(parameters)

    step = options.dt / options.substeps

    gates = Vector{ITensor}()
    if options.order == 1
        gates = vcat(model.getGatesEven(sites, step, parameters), model.getGatesOdd(sites, step, parameters))
    elseif options.order == 2
        even = model.getGatesEven(sites, step / 2.0, parameters)
        gates = vcat(even, model.getGatesOdd(sites, step, parameters), reverse(even))
    else
        throw(DomainError(order, "TEBD not implemented for specified order"))
    end

    time = 0.0
    psi = psi0

    println(length(gates))

    while time < options.tfinal
        for step = 1:options.substeps
            apply(gates, psi; cutoff = options.cutoff)
        end
        time += dt
        println("$time")
    end
end