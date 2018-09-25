using Distributed
using CUDAnative

const ndevices = length(CUDAnative.devices())

# add one worker per device
addprocs(ndevices)

using CuArrays
using DistributedArrays

function distributeCuda(A)
    dA  = distribute(A, procs = workers())
    return DistributedArrays.map_localparts(CuArray, dA)
end

function drandCuda(::Type{T}, dims) where T
    DArray(dims) do I
        ldims = map(length, I)
        reshape(CuArrays.CURAND.curand(T, prod(dims)), dims...)
    end
end

# Set device to be used on each worker
asyncmap(collect(zip(workers(), CUDAnative.devices()))) do (p, d)
    remotecall_wait(() -> CUDAnative.device!(d), p)
    nothing
end

A = drandCuda(Float32, (400,400))
b = drandCuda(Float32, (400,))

sum(A)

# simple broadcast
B = A .^2

C = A .+ A .* sin.(B)

# simple mat * vec
E = A * b
