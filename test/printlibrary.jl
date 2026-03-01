using BibFormatter: printLibrary
using Test
import Base.Filesystem

const fileExtension = Dict(
  :latex => "tex",
  :html => "html",
  :markdown => "md",
  :text => "txt"
)

let fmt = :latex, style = :siam
  outFilename = Filesystem.joinpath(outputDir,"library_$(style).$(fileExtension[fmt])")
  open(outFilename,"w") do outFile
    printLibrary(outFile, fmt, style, bibFile)
  end
end