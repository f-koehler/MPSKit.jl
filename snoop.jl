using SnoopCompileCore

tinf = @snoopi_deep begin
    using MPSToolkit

    disableThreading()

    model = TransverseIsing1D(8)
    options = DMRGOptions(1, getDefaultSweeps(), 10.0, false)
    result = runDMRG(model, options)

    storeDMRGResult("dmrg.h5", result)

    state = result.states[1]

    tebd_options = TEBDOptions(2, 2.0, 0.1, 10, 1e-12)
    model.parameters["hx"] = 1.5
    result = runTEBD(state, model, tebd_options)
    storeTEBDResult("tebd.h5", result)
end

using SnoopCompile

ttot, pcs = SnoopCompile.parcel(tinf)
SnoopCompile.write(joinpath(pwd(), "src", "Precompile"), pcs)
