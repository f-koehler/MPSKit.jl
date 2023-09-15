struct TransverseIsing2D <: SpinHalf
    parameters::Dict{String,Any}
    sites::vector{Index{Int64}}

    TransverseIsing2D(Lx::Int64, Ly::Int64) = new(
        Dict{String,Any}(
            "Lx" => Lx,
            "Ly" => Ly,
            "J" => 1.0,
            "hx" => 1.0,
            "hz" => 0.5,
            "pbc" => false,
        ),
        siteinds("S=1/2", Lx * Ly)
    )
end

function getHamiltonian(model::TransverseIsing2D)::MPO
    ampo = OpSum()

    Lx = model.parameters["Lx"]
    Ly = model.parameters["Ly"]
    J = model.parameters["J"]
    hx = model.parameters["hx"]
    hy = model.parameters["hy"]

    lattice = square_lattice(Lx, Ly; yperiodic=false)
    for b in lattice
        ampo += -4.0 * J
    end

end