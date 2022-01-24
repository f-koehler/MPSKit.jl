using MPSToolkit
using MPSToolkit.ITensors: setmaxdim!, setmindim!, setcutoff!, setnoise!, Sweeps
disableThreading()

L = 4
order = 2

model = TransverseIsing1D(L)
model.parameters["J"] = 1.0
model.parameters["hx"] = 1.0
model.parameters["hz"] = 0.5
model.parameters["pbc"] = false

sweeps = Sweeps(6)
setmaxdim!(sweeps, 10, 20, 100, 500, 1000, 2000)
setcutoff!(sweeps, 1e-11)
dmrgOptions = DMRGOptions(1, sweeps, 0.0, false)

@info "Compute ground state using DMRG"
dmrgResult = runDMRG(model, dmrgOptions)
storeDMRGResult("L_$L/dmrg.h5", dmrgResult)

psi0 = dmrgResult.states[1]

model.parameters["hx"] = 2.0
println(model.parameters)

@info "Run TEBD of order $order"
tebdOptions = TEBDOptions(order, 2.0, 0.1, 5, 1e-12)
tebdResult = runTEBD(psi0, model, tebdOptions)
storeTEBDResult("L_$L/tebd$order.h5", tebdResult)