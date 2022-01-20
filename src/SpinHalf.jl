using ITensors

function getTotalSx(sites::Vector)::MPO
    ampo = OpSum()

    for j = 1:length(sites)
        ampo += 2.0, "Sx", j
    end

    return MPO(ampo, sites)
end

function getTotalSy(sites::Vector)::MPO
    ampo = OpSum()

    for j = 1:length(sites)
        ampo += 2.0, "Sy", j
    end

    return MPO(ampo, sites)
end

function getTotalSz(sites::Vector)::MPO
    ampo = OpSum()

    for j = 1:length(sites)
        ampo += 2.0, "Sz", j
    end

    return MPO(ampo, sites)
end