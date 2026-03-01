using Test
import Base.Filesystem
import BibParser

const outputDir = Filesystem.joinpath(@__DIR__,"output")
Filesystem.mkpath(outputDir)

const bibFilename = Filesystem.joinpath(@__DIR__,"references.bib")
const bibFile = BibParser.parse_file(bibFilename; check=:none)

include("output.jl")
include("specialsymbol.jl")
include("bbl_compare.jl")
include("references2.jl")

include("printlibrary.jl")

include("styles.jl")
