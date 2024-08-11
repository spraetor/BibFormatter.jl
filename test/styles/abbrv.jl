using BibFormatter: BibliographyStyle,OutputFormat,_format2
using Test

function testEntry(key::AbstractString, entry::AbstractString)
  if key == "Article"
    @test entry == raw"""
F.~S. von Last, Junior, F.~M. Last2, and F.~M. Last3.
\newblock This is a title.
\newblock {\em Journal}, v123(b234):1--2, mm yyyy.
\newblock This is a note."""
  end
end

function testLibrary(entries::AbstractDict{String,E}) where E
  for (key,entry) in entries
    testEntry(key, _format2(OutputFormat(:latex),BibliographyStyle(:abbrv),entry))
  end
end


# -----------------------------------------------------------------

testLibrary(bibFile)