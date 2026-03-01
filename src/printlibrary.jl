import Base.Filesystem

function printLibrary(out::IO, fmt::Symbol, style::Symbol, entries::AbstractDict{String,E}) where E
  outputFormat = OutputFormat(fmt)
  println(out, outputLibraryHeader(outputFormat))
  for (key,entry) in entries
    println(out, outputEntry(outputFormat, key, format(entry,style=style,fmt=fmt)))
  end
  println(out, outputLibraryFooter(outputFormat))
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
.smallcaps { font-variant-caps: small-caps; }
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


outputEntry(::OutputFormat, key::AbstractString, entry::AbstractString) = "[$key] " * entry
outputEntry(::OutputFormatLatex, key::AbstractString, entry::AbstractString) = "\\bibitem{$key}\n$entry\n"
outputEntry(::OutputFormatHtml, key::AbstractString, entry::AbstractString) = """
<dt class="bibkey">$key</dt>
<dd class="bibitem" id="bibitem_$key">
$entry
</dd>"""
