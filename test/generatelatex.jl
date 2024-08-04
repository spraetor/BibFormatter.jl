using BibFormatter: styles
import Base.Filesystem

# generte example outputs from bibtext
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