module AcmTest

using BibFormatter: format
using Test

simplifyString(str::AbstractString) = replace(str, r"\n[ ]+" => " ")

function compareBibtexEntries(str1::AbstractString, str2::AbstractString)::Bool
  simplifyString(str1) == simplifyString(str2)
end

function testEntry(key::AbstractString, entry::AbstractString)
  if key == "Article"
    @test compareBibtexEntries(entry, raw"""
{\sc von Last, Junior, F.~S., Last2, F.~M., and Last3, F.~M.}
\newblock This is a title.
\newblock {\em Journal v123}, b234 (mm yyyy), 1--2.
\newblock This is a note.""")
  elseif key == "Book1"
    @test compareBibtexEntries(entry, raw"""
{\sc Last1, F.~M., Last2, F.~M., and Last3, F.~M.}
\newblock {\em This is a title.}, edition~ed., vol.~v123 of {\em Series}.
\newblock Publisher, Address, mm yyyy.
\newblock This is a note.""")
  elseif key == "Book2"
    @test compareBibtexEntries(entry, raw"""
{\sc ELast1, E.~E., ELast2, E.~E., and ELast3, E.~E.}, Eds.
\newblock {\em This is a title.}, edition~ed.
\newblock No.~n234 in Series. Publisher, Address, mm yyyy.
\newblock This is a note.""")
  elseif key == "Booklet"
    @test compareBibtexEntries(entry, raw"""
{\sc Last1, F.~M., Last2, F.~M., and Last3, F.~M.}
\newblock This is a title.
\newblock How it is published, Address, mm yyyy.
\newblock This is a note.""")
  elseif key == "InBook1"
    @test compareBibtexEntries(entry, raw"""
{\sc Last1, F.~M., Last2, F.~M., and Last3, F.~M.}
\newblock {\em This is a title}, edition~ed., vol.~v123 of {\em Series}.
\newblock Publisher, Address, mm yyyy, type Chapter, pp.~1--2.
\newblock This is a note.""")
  elseif key == "InBook2"
    @test compareBibtexEntries(entry, raw"""
{\sc Last1, F.~M., Last2, F.~M., and Last3, F.~M.}
\newblock {\em This is a title.}, edition~ed.
\newblock No.~n234 in Series. Publisher, Address, mm yyyy, type Chapter,
  pp.~1--2.
\newblock This is a note.""")
  elseif key == "InCollection1"
    @test compareBibtexEntries(entry, raw"""
{\sc Last1, F.~M., Last2, F.~M., and Last3, F.~M.}
\newblock This is a title.
\newblock In {\em Booktitle}, E.~E. ELast1, E.~E. ELast2, and E.~E. ELast3,
  Eds., edition~ed., vol.~v123 of {\em Series}. Publisher, Address, mm yyyy,
  type Chapter, pp.~1--2.
\newblock This is a note.""")
  elseif key == "InCollection2"
    @test compareBibtexEntries(entry, raw"""
{\sc Last1, F.~M., Last2, F.~M., and Last3, F.~M.}
\newblock This is a title.
\newblock In {\em Booktitle}, E.~E. ELast1, E.~E. ELast2, and E.~E. ELast3,
  Eds., edition~ed., no.~n234 in Series. Publisher, Address, mm yyyy, type
  Chapter, pp.~1--2.
\newblock This is a note.""")
  elseif key == "Manual"
    @test compareBibtexEntries(entry, raw"""
{\sc Last1, F.~M., Last2, F.~M., and Last3, F.~M.}
\newblock {\em This is a title.}, edition~ed.
\newblock Organization, Address, mm yyyy.
\newblock This is a note.""")
  elseif key == "Master"
    @test compareBibtexEntries(entry, raw"""
{\sc Last, F.~M.}
\newblock This is a title.
\newblock Type, School, Address, mm yyyy.
\newblock This is a note.""")
  elseif key == "PhD"
    @test compareBibtexEntries(entry, raw"""
{\sc Last, F.~M.}
\newblock {\em This is a title.}
\newblock Type, School, Address, mm yyyy.
\newblock This is a note.""")
  elseif key == "Proceedings1"
    @test compareBibtexEntries(entry, raw"""
{\sc ELast1, E.~E., ELast2, E.~E., and ELast3, E.~E.}, Eds.
\newblock {\em This is a title.\/} (Address, mm yyyy), vol.~v123 of {\em
  Series}, Organization, Publisher.
\newblock This is a note.""")
  elseif key == "Proceedings2"
    @test compareBibtexEntries(entry, raw"""
{\sc ELast1, E.~E., ELast2, E.~E., and ELast3, E.~E.}, Eds.
\newblock {\em This is a title.\/} (Address, mm yyyy), no.~n234 in Series,
  Organization, Publisher.
\newblock This is a note.""")
  elseif key == "TechReport"
    @test compareBibtexEntries(entry, raw"""
{\sc Last1, F.~M., Last2, F.~M., and Last3, F.~M.}
\newblock This is a title.
\newblock Type n234, Institution, Address, mm yyyy.
\newblock This is a note.""")
  elseif key == "Unpubished"
    @test compareBibtexEntries(entry, raw"""
{\sc Last1, F.~M., Last2, F.~M., and Last3, F.~M.}
\newblock This is a title.
\newblock This is a note, mm yyyy.""")
  elseif key == "Misc"
    @test compareBibtexEntries(entry, raw"""
{\sc Last1, F.~M., Last2, F.~M., and Last3, F.~M.}
\newblock This is a title.
\newblock How it is published, mm yyyy.
\newblock This is a note.""")
  end
end

function testLibrary(entries::AbstractDict{String,E}) where E
  for (key, entry) in entries
    testEntry(key, format(entry, style = :acm, fmt = :latex))
  end
end

end # module AcmTest

# -----------------------------------------------------------------

AcmTest.testLibrary(bibFile)
