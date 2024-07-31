using BibtexFormatter: BibliographyStyles,bibliographyStyles,format
using Test

import Base.Filesystem
import BibParser

const bibFilename = Filesystem.joinpath(@__DIR__,"references.bib")
const bibFile = BibParser.parse_file(bibFilename)
for style in instances(BibliographyStyles.T)
  println(style)
  for (key,entry) in bibFile
    println("  [$(key)] ",format(entry, style))
  end
end


# generte example outputs from bibtext
if false
  outputDir = Filesystem.joinpath(@__DIR__,"output")
  Filesystem.mkpath(outputDir)
  for style in keys(bibliographyStyles)
    texFilename = Filesystem.joinpath(outputDir,"bibliographystyle_" * style * ".tex")
    open(texFilename,"w") do texFile
      println(texFile, raw"\documentclass{article}")
      println(texFile, raw"\begin{document}")
      println(texFile, raw"\nocite{*}")
      println(texFile, raw"\bibliographystyle{" * style * "}")
      println(texFile, raw"\bibliography{" * Filesystem.relpath(bibFilename,outputDir) * "}")
      println(texFile, raw"\end{document}")
    end

    run(Cmd(`latexmk -pdf $(basename(texFilename))`, dir=outputDir))
  end
  run(Cmd(`latexmk -c`, dir=outputDir))
end