using BibFormatter
using Documenter

DocMeta.setdocmeta!(BibFormatter, :DocTestSetup, :(using BibFormatter); recursive=true)

makedocs(;
    modules=[BibFormatter],
    authors="Simon Praetorius <simon.praetorius@tu-dresden.de> and contributors",
    sitename="BibFormatter.jl",
    format=Documenter.HTML(;
        canonical="https://spraetor.github.io/BibFormatter.jl/stable",
        edit_link="main",
        assets=["assets/custom.css"],
    ),
    pages=[
        "Home" => "index.md",
        "Examples" => "examples.md",
        "Adding a Style" => "adding_style.md",
        "Developer Internals" => "internals.md",
    ],
)

deploydocs(;
    repo="github.com/spraetor/BibFormatter.jl",
    devbranch="main",
    versions=["stable" => "v^", "v#.#", "dev" => "dev"],
)
