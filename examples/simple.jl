using Distributed
using CUDAnative

const ndevices = length(CUDAnative.devices())

# add one worker per device
addprocs(ndevices)

using CuArrays
using DistributedArrays

# Set device to be used on each worker
asyncmap(collect(zip(workers(), CUDAnative.devices()))) do (p, d)
    remotecall_wait(() -> CUDAnative.device!(d), p)
    nothing
end

A = DArray((400, 400)) do I
    dims = map(length, I)
    reshape(CuArrays.CURAND.curand(Float32, prod(dims)), dims)
end;

sum(A)

# simple broadcast
B = A .^2

C = A .+ A .* sin.(B)