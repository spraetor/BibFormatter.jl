import BibParser
import Base.Filesystem
using Test

@testset "References2 vs BibTeX (abbrv)" begin
  bib2 = BibParser.parse_file(Filesystem.joinpath(@__DIR__, "references2.bib"); check=:none)
  bblPath = Filesystem.joinpath(@__DIR__, "bbl", "abbrv_references2.bbl")
  testStyleAgainstBbl(bib2, :abbrv, bblPath)
end
