module ApalikeTest

using BibFormatter: format
using Test

simplifyString(str::AbstractString) = replace(str, r"\n[ ]+" => " ")

function compareBibtexEntries(str1::AbstractString, str2::AbstractString)::Bool
  simplifyString(str1) == simplifyString(str2)
end

function testEntry(key::AbstractString, entry::AbstractString)
  if key == "Article"
    @test compareBibtexEntries(entry, raw"""
Von Last, Junior, F.~S., Last2, F.~M., and Last3, F.~M. (yyyy).
\newblock This is a title.
\newblock {\em Journal}, v123(b234):1--2.
\newblock This is a note.""")
  elseif key == "Book1"
    @test compareBibtexEntries(entry, raw"""
Last1, F.~M., Last2, F.~M., and Last3, F.~M. (yyyy).
\newblock {\em This is a title.}, volume v123 of {\em Series}.
\newblock Publisher, Address, edition edition.
\newblock This is a note.""")
  elseif key == "Book2"
    @test compareBibtexEntries(entry, raw"""
ELast1, E.~E., ELast2, E.~E., and ELast3, E.~E., editors (yyyy).
\newblock {\em This is a title.}
\newblock Number n234 in Series. Publisher, Address, edition edition.
\newblock This is a note.""")
  elseif key == "Booklet"
    @test compareBibtexEntries(entry, raw"""
Last1, F.~M., Last2, F.~M., and Last3, F.~M. (yyyy).
\newblock This is a title.
\newblock How it is published, Address.
\newblock This is a note.""")
  elseif key == "InBook1"
    @test compareBibtexEntries(entry, raw"""
Last1, F.~M., Last2, F.~M., and Last3, F.~M. (yyyy).
\newblock {\em This is a title}, volume v123 of {\em Series}, type Chapter,
  pages 1--2.
\newblock Publisher, Address, edition edition.
\newblock This is a note.""")
  elseif key == "InBook2"
    @test compareBibtexEntries(entry, raw"""
Last1, F.~M., Last2, F.~M., and Last3, F.~M. (yyyy).
\newblock {\em This is a title.}, type Chapter, pages 1--2.
\newblock Number n234 in Series. Publisher, Address, edition edition.
\newblock This is a note.""")
  elseif key == "InCollection1"
    @test compareBibtexEntries(entry, raw"""
Last1, F.~M., Last2, F.~M., and Last3, F.~M. (yyyy).
\newblock This is a title.
\newblock In ELast1, E.~E., ELast2, E.~E., and ELast3, E.~E., editors, {\em
  Booktitle}, volume v123 of {\em Series}, type Chapter, pages 1--2. Publisher,
  Address, edition edition.
\newblock This is a note.""")
  elseif key == "InCollection2"
    @test compareBibtexEntries(entry, raw"""
Last1, F.~M., Last2, F.~M., and Last3, F.~M. (yyyy).
\newblock This is a title.
\newblock In ELast1, E.~E., ELast2, E.~E., and ELast3, E.~E., editors, {\em
  Booktitle}, number n234 in Series, type Chapter, pages 1--2. Publisher,
  Address, edition edition.
\newblock This is a note.""")
  elseif key == "Manual"
    @test compareBibtexEntries(entry, raw"""
Last1, F.~M., Last2, F.~M., and Last3, F.~M. (yyyy).
\newblock {\em This is a title.}
\newblock Organization, Address, edition edition.
\newblock This is a note.""")
  elseif key == "Master"
    @test compareBibtexEntries(entry, raw"""
Last, F.~M. (yyyy).
\newblock This is a title.
\newblock Type, School, Address.
\newblock This is a note.""")
  elseif key == "PhD"
    @test compareBibtexEntries(entry, raw"""
Last, F.~M. (yyyy).
\newblock {\em This is a title.}
\newblock Type, School, Address.
\newblock This is a note.""")
  elseif key == "Proceedings1"
    @test compareBibtexEntries(entry, raw"""
ELast1, E.~E., ELast2, E.~E., and ELast3, E.~E., editors (yyyy).
\newblock {\em This is a title.}, volume v123 of {\em Series}, Address.
  Organization, Publisher.
\newblock This is a note.""")
  elseif key == "Proceedings2"
    @test compareBibtexEntries(entry, raw"""
ELast1, E.~E., ELast2, E.~E., and ELast3, E.~E., editors (yyyy).
\newblock {\em This is a title.}, number n234 in Series, Address. Organization,
  Publisher.
\newblock This is a note.""")
  elseif key == "TechReport"
    @test compareBibtexEntries(entry, raw"""
Last1, F.~M., Last2, F.~M., and Last3, F.~M. (yyyy).
\newblock This is a title.
\newblock Type n234, Institution, Address.
\newblock This is a note.""")
  elseif key == "Unpubished"
    @test compareBibtexEntries(entry, raw"""
Last1, F.~M., Last2, F.~M., and Last3, F.~M. (yyyy).
\newblock This is a title.
\newblock This is a note.""")
  elseif key == "Misc"
    @test compareBibtexEntries(entry, raw"""
Last1, F.~M., Last2, F.~M., and Last3, F.~M. (yyyy).
\newblock This is a title.
\newblock How it is published.
\newblock This is a note.""")
  end
end

function testLibrary(entries::AbstractDict{String,E}) where E
  for (key, entry) in entries
    testEntry(key, format(entry, style = :apalike, fmt = :latex))
  end
end

end # module ApalikeTest

# -----------------------------------------------------------------

ApalikeTest.testLibrary(bibFile)
