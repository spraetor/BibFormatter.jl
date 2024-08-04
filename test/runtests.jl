using Test
import Base.Filesystem

const outputDir = Filesystem.joinpath(@__DIR__,"output")
Filesystem.mkpath(outputDir)

include("printlibrary.jl")
# include("generatelatex.jl")