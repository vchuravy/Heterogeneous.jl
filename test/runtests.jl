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

# Setup environment
using Pkg

branch = haskey(ENV, "GITLAB_CI") ? ENV["CI_COMMIT_REF_NAME"] : nothing
for package in ("GPUArrays", "CuArrays", "DistributedArrays")
    try
        if branch === nothing
            branch = chomp(read(`git -C $(@__DIR__) rev-parse --abbrev-ref HEAD`, String))
            branch == "HEAD" && error("in detached HEAD state")
        end
        Pkg.add(PackageSpec(name=package, rev=String(branch)))
        @info "Installed $package from $branch branch"
    catch ex
        @warn "Could not install $package from same branch, trying master branch" exception=ex
        Pkg.add(PackageSpec(name=package, rev="master"))
    end
end

using Test
include("examples.jl")
