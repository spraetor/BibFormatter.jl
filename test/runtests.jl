using Test
import Base.Filesystem
import BibParser

const outputDir = Filesystem.joinpath(@__DIR__,"output")
Filesystem.mkpath(outputDir)

const bibFilename = Filesystem.joinpath(@__DIR__,"references.bib")
const bibFile = BibParser.parse_file(bibFilename)

include("output.jl")

include("printlibrary.jl")
# include("generatelatex.jl")

include("styles/abbrv.jl")