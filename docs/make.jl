using Documenter, OPFSampler

makedocs(;
    modules=[OPFSampler],
    format=Documenter.HTML(),
    pages=[
        "Home" => "index.md",
    ],
    repo="https://github.com/invenia/OPFSampler.jl/blob/{commit}{path}#L{line}",
    sitename="OPFSampler.jl",
    authors="Invenia Technical Computing Corporation",
    assets=[
        "assets/invenia.css",
        "assets/logo.png",
    ],
)

deploydocs(;
    repo="github.com/invenia/OPFSampler.jl",
)
