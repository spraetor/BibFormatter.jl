using BibFormatter: styles,format,outputEntry,OutputFormat
using Test

import Base.Filesystem
import BibParser

const bibFilename = Filesystem.joinpath(@__DIR__,"references.bib")
const bibFile = BibParser.parse_file(bibFilename)
const fmt = :html
for style in (:acm,) # styles
  println(style)
  for (key,entry) in bibFile
    println(outputEntry(OutputFormat(fmt), key, format(entry, style, fmt)))
  end
end


# generte example outputs from bibtext
if false
  outputDir = Filesystem.joinpath(@__DIR__,"output")
  Filesystem.mkpath(outputDir)
  for style in keys(styles)
    texFilename = Filesystem.joinpath(outputDir,"bibliographystyle_" * string(style) * ".tex")
    open(texFilename,"w") do texFile
      println(texFile, "\\documentclass{article}")
      println(texFile, "\\begin{document}")
      println(texFile, "\\nocite{*}")
      println(texFile, "\\bibliographystyle{" * string(style) * "}")
      println(texFile, "\\bibliography{" * Filesystem.relpath(bibFilename,outputDir) * "}")
      println(texFile, "\\end{document}")
    end

    run(Cmd(`latexmk -pdf $(basename(texFilename))`, dir=outputDir))
  end
  run(Cmd(`latexmk -c`, dir=outputDir))
end