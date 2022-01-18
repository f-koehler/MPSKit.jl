using SnoopCompileCore

tinf = @snoopi_deep begin
    using MPSKit

    model = getModel("TransverseIsing1D")
    parameters = model.getDefaultParameters()
    options = DMRGOptions(1, getDefaultSweeps(), 10.0)
    runDMRG(model, parameters, options)
end

using SnoopCompile

ttot, pcs = SnoopCompile.parcel(tinf)
println(ttot)
println(pcs)
SnoopCompile.write(joinpath(pwd(), "src", "Precompile"), pcs)