using BibFormatter: styles
import Base.Filesystem: basename, joinpath, relpath, mkpath

const defaultBblStyles = (
  :abbrv, :acm, :alpha, :apalike, :ieeetr, :plain, :siam, :unsrt,
  :abbrvurl, :plainurl, :alphaurl, :unsrturl,
)

"""Write one minimal LaTeX driver for `style` that cites all entries."""
function _writeBibstyleTexFile(outputDir::AbstractString, bibFilename::AbstractString, style::Symbol)
  texFilename = joinpath(outputDir, "bibliographystyle_" * string(style) * ".tex")
  open(texFilename, "w") do texFile
    println(texFile, "\\documentclass{article}")
    println(texFile, "\\usepackage{hyperref}")
    println(texFile, "\\begin{document}")
    println(texFile, "\\nocite{*}")
    println(texFile, "\\bibliographystyle{" * string(style) * "}")
    println(texFile, "\\bibliography{" * relpath(bibFilename, outputDir) * "}")
    println(texFile, "\\end{document}")
  end
  texFilename
end

"""
Generate one `.bbl` fixture from `bibFilename` for `style`.

Steps:
1. write LaTeX file
2. run `latex`
3. run `bibtex`
4. copy resulting `.bbl` to `bblDir/<style>.bbl`
"""
function generateStyleBblData(outputDir::AbstractString, bibFilename::AbstractString;
  style::Symbol, bblDir::AbstractString = joinpath(@__DIR__, "bbl"))

  mkpath(outputDir)
  mkpath(bblDir)

  texFilename = _writeBibstyleTexFile(outputDir, bibFilename, style)
  stem = replace(basename(texFilename), ".tex" => "")

  run(Cmd(`latex -interaction=nonstopmode $(basename(texFilename))`, dir=outputDir))
  run(Cmd(`bibtex $stem`, dir=outputDir))
  run(Cmd(`latex -interaction=nonstopmode $(basename(texFilename))`, dir=outputDir))

  sourceBbl = joinpath(outputDir, stem * ".bbl")
  targetBbl = joinpath(bblDir, string(style) * ".bbl")
  cp(sourceBbl, targetBbl; force=true)
  targetBbl
end

"""
Generate `.bbl` fixtures for all test styles.

If `style` is passed, generate only that style.
Otherwise generate all styles listed in `defaultBblStyles`.
"""
function generateBblTestData(outputDir::AbstractString, bibFilename::AbstractString;
  style::Union{Nothing,Symbol}=nothing, bblDir::AbstractString = joinpath(@__DIR__, "bbl"))

  selected = isnothing(style) ? collect(defaultBblStyles) : [style]
  for s in selected
    haskey(styles, s) || error("Unknown style in BibFormatter.styles: $s")
    generateStyleBblData(outputDir, bibFilename; style=s, bblDir=bblDir)
  end
  nothing
end

"""Generate fixtures for all styles currently available in `BibFormatter.styles`."""
function generateAllAvailableBblData(outputDir::AbstractString, bibFilename::AbstractString;
  bblDir::AbstractString = joinpath(@__DIR__, "bbl"))
  for s in keys(styles)
    generateStyleBblData(outputDir, bibFilename; style=s, bblDir=bblDir)
  end
  nothing
end
