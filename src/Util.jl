export disableThreading

function disableThreading()
    Strided.disable_threads()
    ITensors.disable_threaded_blocksparse()
    BLAS.set_num_threads(1)
end