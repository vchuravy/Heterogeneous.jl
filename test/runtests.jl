# Pkg.test runs with --check_bounds=1, forcing all bounds checks.
# This is incompatible with CUDAnative (see JuliaGPU/CUDAnative.jl#98)
if Base.JLOptions().check_bounds == 1
    @warn "Running with --check-bounds=yes, restarting tests."
    file = @__FILE__
    run(```
        $(Base.julia_cmd())
            --code-coverage=$(("none", "user", "all")[Base.JLOptions().code_coverage + 1])
            --color=$(Base.have_color ? "yes" : "no")
            --compiled-modules=$(Bool(Base.JLOptions().use_compiled_modules) ? "yes" : "no")
            --startup-file=$(Base.JLOptions().startupfile == 1 ? "yes" : "no")
            --track-allocation=$(("none", "user", "all")[Base.JLOptions().malloc_log + 1])
            $file
      ```)
    exit()
end

using CUDAnative
using Test

if CUDAnative.configured
    include("examples.jl")
else
    @warn("CUDAnative.jl has not been configured; skipping on-device tests.")
end
