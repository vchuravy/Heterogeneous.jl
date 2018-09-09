using Documenter, Heterogeneous

makedocs(
    modules = [Heterogeneous],
    format = :html,
    sitename = "Heterogeneous.jl",
    pages = [
        "Home"    => "index.md",
    ],
    doctest = true
)

deploydocs(
    repo = "github.com/vchuravy/Heterogeneous.jl.git",
    julia = "",
    osname = "",
    # no need to build anything here, re-use output of `makedocs`
    target = "build",
    deps = nothing,
    make = nothing
)
