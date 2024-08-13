using BibFormatter: BibliographyStyle,OutputFormat,_format2
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
\newblock This is a note.""")
  elseif key == "Book1"
    @test compareBibtexEntries(entry, raw"""
F.~M. Last1, F.~M. Last2, and F.~M. Last3.
\newblock {\em This is a title.}, volume v123 of {\em Series}.
\newblock Publisher, Address, edition edition, mm yyyy.
\newblock This is a note.""")
  elseif key == "Book2"
    @test compareBibtexEntries(entry, raw"""
E.~E. ELast1, E.~E. ELast2, and E.~E. ELast3, editors.
\newblock {\em This is a title.}
\newblock Number n234 in Series. Publisher, Address, edition edition, mm yyyy.
\newblock This is a note.""")
  elseif key == "Booklet"
    @test compareBibtexEntries(entry, raw"""
F.~M. Last1, F.~M. Last2, and F.~M. Last3.
\newblock This is a title.
\newblock How it is published, Address, mm yyyy.
\newblock This is a note.""")
  elseif key == "InBook1"
    @test compareBibtexEntries(entry, raw"""
F.~M. Last1, F.~M. Last2, and F.~M. Last3.
\newblock {\em This is a title}, volume v123 of {\em Series}, type Chapter,
  pages 1--2.
\newblock Publisher, Address, edition edition, mm yyyy.
\newblock This is a note.""")
  elseif key == "InBook2"
    @test compareBibtexEntries(entry, raw"""
F.~M. Last1, F.~M. Last2, and F.~M. Last3.
\newblock {\em This is a title.}, type Chapter, pages 1--2.
\newblock Number n234 in Series. Publisher, Address, edition edition, mm yyyy.
\newblock This is a note.""")
  elseif key == "InCollection1"
    @test compareBibtexEntries(entry, raw"""
F.~M. Last1, F.~M. Last2, and F.~M. Last3.
\newblock This is a title.
\newblock In E.~E. ELast1, E.~E. ELast2, and E.~E. ELast3, editors, {\em
  Booktitle}, volume v123 of {\em Series}, type Chapter, pages 1--2. Publisher,
  Address, edition edition, mm yyyy.
\newblock This is a note.""")
  elseif key == "InCollection2"
    @test compareBibtexEntries(entry, raw"""
F.~M. Last1, F.~M. Last2, and F.~M. Last3.
\newblock This is a title.
\newblock In E.~E. ELast1, E.~E. ELast2, and E.~E. ELast3, editors, {\em
  Booktitle}, number n234 in Series, type Chapter, pages 1--2. Publisher,
  Address, edition edition, mm yyyy.
\newblock This is a note.""")
elseif key == "Manual"
  @test compareBibtexEntries(entry, raw"""
F.~M. Last1, F.~M. Last2, and F.~M. Last3.
\newblock {\em This is a title.}
\newblock Organization, Address, edition edition, mm yyyy.
\newblock This is a note.""")
elseif key == "Master"
  @test compareBibtexEntries(entry, raw"""
F.~M. Last.
\newblock This is a title.
\newblock Type, School, Address, mm yyyy.
\newblock This is a note.""")
elseif key == "PhD"
  @test compareBibtexEntries(entry, raw"""
F.~M. Last.
\newblock {\em This is a title.}
\newblock Type, School, Address, mm yyyy.
\newblock This is a note.""")
elseif key == "Proceedings1"
  @test compareBibtexEntries(entry, raw"""
E.~E. ELast1, E.~E. ELast2, and E.~E. ELast3, editors.
\newblock {\em This is a title.}, volume v123 of {\em Series}, Address, mm
  yyyy. Organization, Publisher.
\newblock This is a note.""")
elseif key == "Proceedings2"
  @test compareBibtexEntries(entry, raw"""
E.~E. ELast1, E.~E. ELast2, and E.~E. ELast3, editors.
\newblock {\em This is a title.}, number n234 in Series, Address, mm yyyy.
  Organization, Publisher.
\newblock This is a note.""")
elseif key == "TechReport"
  @test compareBibtexEntries(entry, raw"""
F.~M. Last1, F.~M. Last2, and F.~M. Last3.
\newblock This is a title.
\newblock Type n234, Institution, Address, mm yyyy.
\newblock This is a note.""")
elseif key == "Unpubished"
  @test compareBibtexEntries(entry, raw"""
F.~M. Last1, F.~M. Last2, and F.~M. Last3.
\newblock This is a title.
\newblock This is a note, mm yyyy.""")
elseif key == "Misc"
  @test compareBibtexEntries(entry, raw"""
F.~M. Last1, F.~M. Last2, and F.~M. Last3.
\newblock This is a title.
\newblock How it is published, mm yyyy.
\newblock This is a note.""")
  end
end

function testLibrary(entries::AbstractDict{String,E}) where E
  for (key,entry) in entries
    testEntry(key, _format2(OutputFormat(:latex),BibliographyStyle(:abbrv),entry))
  end
end


# -----------------------------------------------------------------

testLibrary(bibFile)