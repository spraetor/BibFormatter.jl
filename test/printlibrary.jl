using BibFormatter: BibliographyStyle,OutputFormat,OutputFormatHtml,OutputFormatLatex,_format2
using Test

import Base.Filesystem

function printLibrary(out::IO, fmt::OutputFormat, style::BibliographyStyle, entries::AbstractDict{String,E}) where E
  println(out, outputLibraryHeader(fmt))
  for (key,entry) in entries
    println(out, outputEntry(fmt, key, _format2(fmt,style,entry)))
  end
  println(out, outputLibraryFooter(fmt))
end

outputLibraryHeader(fmt::OutputFormat) = ""
outputLibraryHeader(fmt::OutputFormatLatex) = """
\\documentclass{article}
\\begin{document}
\\begin{thebibliography}{99}"""
outputLibraryHeader(fmt::OutputFormatHtml) = """
<html>
<head>
<style>
.sc { font-variant-caps: small-caps; }
</style>
</head>
<body>
<h1>References</h1>
<dl>"""


outputLibraryFooter(fmt::OutputFormat) = ""
outputLibraryFooter(fmt::OutputFormatLatex) = """
\\end{thebibliography}
\\end{document}"""
outputLibraryFooter(fmt::OutputFormatHtml) = """
</dl>
</body>
</html>"""


outputEntry(fmt::OutputFormat, key::AbstractString, entry::AbstractString) = "[$key] " * entry
outputEntry(fmt::OutputFormatLatex, key::AbstractString, entry::AbstractString) = "\\bibitem{$key}\n$entry\n"
outputEntry(fmt::OutputFormatHtml, key::AbstractString, entry::AbstractString) = """
<dt class="bibkey">$key</dt>
<dd class="bibitem" id="bibitem_$key">
$entry
</dd>"""


# -----------------------------------------------------------------

const fileExtension = Dict(
  :latex => "tex",
  :html => "html",
  :markdown => "md",
  :text => "txt"
)

let fmt = :latex, style = :abbrv
  outFilename = Filesystem.joinpath(outputDir,"library_$(style).$(fileExtension[fmt])")
  open(outFilename,"w") do outFile
    printLibrary(outFile, OutputFormat(fmt), BibliographyStyle(style), bibFile)
  end
end