using MPSToolkit
using Test

# @testset "MPSToolkit.jl" begin
#     # Write your tests here.
# end

@testset "TransverseIsing1D" begin
    model = TransverseIsing1D(3)
    @test length(getGatesEven(model, 0.1)) == 1
    @test length(getGatesOdd(model, 0.1)) == 2

    model = TransverseIsing1D(4)
    @test length(getGatesEven(model, 0.1)) == 2
    @test length(getGatesOdd(model, 0.1)) == 2

    # test ground state in ordered phase
    dmrg_options = DMRGOptions()
    for L in [4, 5, 8, 16]
        model = TransverseIsing1D(L)
        model.parameters["hx"] = 0.0
        model.parameters["hz"] = 1.0
        results = runDMRG(model, dmrg_options)
        @test results.observables[1]["H"][1] ≈ -2 * L + 1
        @test abs(results.observables[1]["Sx"][1]) < 1e-12
        @test results.observables[1]["Sz"][1] ≈ L
        @test results.localOperators[1]["sz"] ≈ fill(1.0, (L,))
        # FIXME: test sx and sz_sz
    end
end

