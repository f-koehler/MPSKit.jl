using MPSToolkit
using Documenter

DocMeta.setdocmeta!(MPSToolkit, :DocTestSetup, :(using MPSToolkit); recursive = true)

makedocs(;
    modules = [MPSToolkit],
    authors = "Fabian Köhler <fabian.koehler@protonmail.ch>",
    repo = "https://github.com/f-koehler/MPSToolkit.jl/blob/{commit}{path}#{line}",
    sitename = "MPSToolkit.jl",
    format = Documenter.HTML(;
        prettyurls = get(ENV, "CI", "false") == "true",
        canonical = "https://f-koehler.github.io/MPSToolkit.jl",
        assets = String[]
    ),
    pages = [
        "Home" => "index.md",
    ]
)

deploydocs(;
    repo = "github.com/f-koehler/MPSToolkit.jl",
    devbranch = "main"
)
