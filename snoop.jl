using SnoopCompileCore

tinf = @snoopi_deep begin
    using MPSKit

    disableThreading()

    model = getModel("TransverseIsing1D")
    parameters = model.getDefaultParameters()
    options = DMRGOptions(1, getDefaultSweeps(), 10.0)
    result = runDMRG(model, parameters, options)

    storeDMRGResult("dmrg.h5", result)
end

using SnoopCompile

ttot, pcs = SnoopCompile.parcel(tinf)
println(ttot)
println(pcs)
SnoopCompile.write(joinpath(pwd(), "src", "Precompile"), pcs)