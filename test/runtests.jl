function julia_cmd(cmd)
    return `
        $(Base.julia_cmd())
        --color=$(Base.have_color ? "yes" : "no")
        --compiled-modules=$(Base.JLOptions().use_compiled_modules != 0 ? "yes" : "no")
        --history-file=no
        --startup-file=$(Base.JLOptions().startupfile != 2 ? "yes" : "no")
        --code-coverage=$(["none", "user", "all"][1+Base.JLOptions().code_coverage])
        $cmd
    `
end

# Pkg.test runs with --check_bounds=1, forcing all bounds checks.
# This is incompatible with CUDAnative (see JuliaGPU/CUDAnative.jl#98)
if Base.JLOptions().check_bounds == 1
    @warn "Running with --check-bounds=yes, restarting tests."
    file = @__FILE__
    run(julia_cmd(`$file`))
    exit()
end

using CUDAnative
using Test

if CUDAnative.configured
    include("examples.jl")
else
    @warn("CUDAnative.jl has not been configured; skipping on-device tests.")
end
