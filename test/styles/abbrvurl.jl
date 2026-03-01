module AbbrvUrlTest

using BibFormatter: format
using Test

simplifyString(str::AbstractString) = replace(str, r"\n[ ]+" => " ")

function compareBibtexEntries(str1::AbstractString, str2::AbstractString)::Bool
  simplifyString(str1) == simplifyString(str2)
end

function testEntry(key::AbstractString, entry::AbstractString)
  if key == "Article"
    @test compareBibtexEntries(entry, raw"""
F.~S. von Last, Junior, F.~M. Last2, and F.~M. Last3.
\newblock This is a title.
\newblock {\em Journal}, v123(b234):1--2, mm yyyy.
\newblock This is a note.
\newblock URL: \href{https://example.org/articles/this-is-a-title}{https://example.org/articles/this-is-a-title} [cited 26 August 2009].
\newblock \href{http://arxiv.org/abs/1234.56789}{arXiv:1234.56789}.
\newblock \href{https://doi.org/10.1234/56.abc.123}{doi:10.1234/56.abc.123}.
\newblock \href{http://www.ncbi.nlm.nih.gov/pubmed/34567890}{PMID:34567890}.""")
  elseif key == "Book1"
    @test occursin(raw"\newblock URL: \href{https://example.org/books/book1}{https://example.org/books/book1} [cited 01 March 2026].", entry)
    @test occursin(raw"\newblock \href{https://doi.org/10.5555/book1.2026}{doi:10.5555/book1.2026}.", entry)
  elseif key == "Manual"
    @test occursin(raw"\newblock URL: \href{https://example.org/manuals/manual}{https://example.org/manuals/manual} [cited 01 March 2026].", entry)
  elseif key == "Misc"
    @test occursin(raw"\newblock \href{https://doi.org/10.7777/misc.42}{doi:10.7777/misc.42}.", entry)
  elseif key == "WebPage"
    @test compareBibtexEntries(entry, raw"""
The world wide web consortium, [online].
\newblock 2009.
\newblock URL: \href{http://www.w3.org}{http://www.w3.org} [cited 26 August 2009].""")
  end
end

function testLibrary(entries::AbstractDict{String,E}) where E
  for (key, entry) in entries
    testEntry(key, format(entry, style=:abbrvurl, fmt=:latex))
  end
end

end # module AbbrvUrlTest

# -----------------------------------------------------------------

AbbrvUrlTest.testLibrary(bibFile)
