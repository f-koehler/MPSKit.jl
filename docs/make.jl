using MPSKit
using Documenter

DocMeta.setdocmeta!(MPSKit, :DocTestSetup, :(using MPSKit); recursive = true)

makedocs(;
    modules = [MPSKit],
    authors = "Fabian Köhler <fabian.koehler@protonmail.ch>",
    repo = "https://github.com/f-koehler/MPSKit.jl/blob/{commit}{path}#{line}",
    sitename = "MPSKit.jl",
    format = Documenter.HTML(;
        prettyurls = get(ENV, "CI", "false") == "true",
        canonical = "https://f-koehler.github.io/MPSKit.jl",
        assets = String[]
    ),
    pages = [
        "Home" => "index.md",
    ]
)

deploydocs(;
    repo = "github.com/f-koehler/MPSKit.jl",
    devbranch = "main"
)
