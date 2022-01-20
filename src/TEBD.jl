mutable struct TEBDOptions
    order::Int64
    tfinal::Float64
    dt::Float64
    substeps::Int64
    cutoff::Float64
end

function runTEBD(psi0::MPS, model::Model, options::TEBDOptions)
    sites = model.sites

    step = options.dt / options.substeps

    gates = ITensor[]
    hj = op("Sz", sites[1]) * op("Sz", sites[2])
    if options.order == 1
        gates = vcat(getGatesEven(model, step), getGatesOdd(model, step))
    elseif options.order == 2
        even = getGatesEven(model, step / 2.0)
        gates = vcat(even, getGatesOdd(model, step), reverse(even))
    else
        throw(DomainError(order, "TEBD not implemented for specified order"))
    end

    time = 0.0
    psi = psi0

    while time < options.tfinal
        for step = 1:options.substeps
            apply(gates, psi; cutoff = options.cutoff)
        end
        time += options.dt
        println("$time")
    end
end