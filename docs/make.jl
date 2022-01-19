using MPSTools
using Documenter

DocMeta.setdocmeta!(MPSTools, :DocTestSetup, :(using MPSTools); recursive = true)

makedocs(;
    modules = [MPSTools],
    authors = "Fabian Köhler <fabian.koehler@protonmail.ch>",
    repo = "https://github.com/f-koehler/MPSTools.jl/blob/{commit}{path}#{line}",
    sitename = "MPSTools.jl",
    format = Documenter.HTML(;
        prettyurls = get(ENV, "CI", "false") == "true",
        canonical = "https://f-koehler.github.io/MPSTools.jl",
        assets = String[]
    ),
    pages = [
        "Home" => "index.md",
    ]
)

deploydocs(;
    repo = "github.com/f-koehler/MPSTools.jl",
    devbranch = "main"
)
