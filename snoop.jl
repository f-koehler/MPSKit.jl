using SnoopCompileCore

tinf = @snoopi_deep begin
    using MPSKit

    disableThreading()

    model = getModel("TransverseIsing1D")
    parameters = model.getDefaultParameters()
    options = DMRGOptions(1, getDefaultSweeps(), 10.0, false)
    result = runDMRG(model, parameters, options)

    storeDMRGResult("dmrg.h5", result)

    state = result.states[1]

    parameters_quenched = parameters
    parameters_quenched["hx"] = 1.5
    tebd_options = TEBDOptions(2, 2.0, 0.1, 10, 1e-12)
    # runTEBD(state, model, parameters_quenched, tebd_options)
end

using SnoopCompile

ttot, pcs = SnoopCompile.parcel(tinf)
SnoopCompile.write(joinpath(pwd(), "src", "Precompile"), pcs)