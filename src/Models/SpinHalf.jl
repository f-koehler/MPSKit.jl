abstract type SpinHalf <: Model end

function getTotalSx(model::SpinHalf)::MPO
    ampo = OpSum()

    for j = 1:length(model.sites)
        ampo += 2.0, "Sx", j
    end

    return MPO(ampo, model.sites)
end

function getTotalSy(model::SpinHalf)::MPO
    ampo = OpSum()

    for j = 1:length(model.sites)
        ampo += 2.0, "Sy", j
    end

    return MPO(ampo, model.sites)
end

function getTotalSz(model::SpinHalf)::MPO
    ampo = OpSum()

    for j = 1:length(model.sites)
        ampo += 2.0, "Sz", j
    end

    return MPO(ampo, model.sites)
end