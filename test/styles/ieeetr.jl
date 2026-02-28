module IeeetrTest

using BibFormatter: format
using Test

simplifyString(str::AbstractString) = replace(str, r"\n[ ]+" => " ")

function compareBibtexEntries(str1::AbstractString, str2::AbstractString)::Bool
  simplifyString(str1) == simplifyString(str2)
end

function testEntry(key::AbstractString, entry::AbstractString)
  if key == "Article"
    @test compareBibtexEntries(entry, raw"""
F.~S. von Last, Junior, F.~M. Last2, and F.~M. Last3, ``This is a title.,''
  {\em Journal}, vol.~v123, pp.~1--2, mm yyyy.
\newblock This is a note.""")
  elseif key == "Book1"
    @test compareBibtexEntries(entry, raw"""
F.~M. Last1, F.~M. Last2, and F.~M. Last3, {\em This is a title.}, vol.~v123 of
  {\em Series}.
\newblock Address: Publisher, edition~ed., mm yyyy.
\newblock This is a note.""")
  elseif key == "Book2"
    @test compareBibtexEntries(entry, raw"""
E.~E. ELast1, E.~E. ELast2, and E.~E. ELast3, eds., {\em This is a title.}
\newblock No.~n234 in Series, Address: Publisher, edition~ed., mm yyyy.
\newblock This is a note.""")
  elseif key == "Booklet"
    @test compareBibtexEntries(entry, raw"""
F.~M. Last1, F.~M. Last2, and F.~M. Last3, ``This is a title..'' How it is
  published, Address, mm yyyy.
\newblock This is a note.""")
  elseif key == "InBook1"
    @test compareBibtexEntries(entry, raw"""
F.~M. Last1, F.~M. Last2, and F.~M. Last3, {\em This is a title}, vol.~v123 of
  {\em Series}, type Chapter, pp.~1--2.
\newblock Address: Publisher, edition~ed., mm yyyy.
\newblock This is a note.""")
  elseif key == "InBook2"
    @test compareBibtexEntries(entry, raw"""
F.~M. Last1, F.~M. Last2, and F.~M. Last3, {\em This is a title.}, type
  Chapter, pp.~1--2.
\newblock No.~n234 in Series, Address: Publisher, edition~ed., mm yyyy.
\newblock This is a note.""")
  elseif key == "InCollection1"
    @test compareBibtexEntries(entry, raw"""
F.~M. Last1, F.~M. Last2, and F.~M. Last3, ``This is a title.,'' in {\em
  Booktitle} (E.~E. ELast1, E.~E. ELast2, and E.~E. ELast3, eds.), vol.~v123 of
  {\em Series}, type Chapter, pp.~1--2, Address: Publisher, edition~ed., mm
  yyyy.
\newblock This is a note.""")
  elseif key == "InCollection2"
    @test compareBibtexEntries(entry, raw"""
F.~M. Last1, F.~M. Last2, and F.~M. Last3, ``This is a title.,'' in {\em
  Booktitle} (E.~E. ELast1, E.~E. ELast2, and E.~E. ELast3, eds.), no.~n234 in
  Series, type Chapter, pp.~1--2, Address: Publisher, edition~ed., mm yyyy.
\newblock This is a note.""")
  elseif key == "Manual"
    @test compareBibtexEntries(entry, raw"""
F.~M. Last1, F.~M. Last2, and F.~M. Last3, {\em This is a title.}
\newblock Organization, Address, edition~ed., mm yyyy.
\newblock This is a note.""")
  elseif key == "Master"
    @test compareBibtexEntries(entry, raw"""
F.~M. Last, ``This is a title.,'' type, School, Address, mm yyyy.
\newblock This is a note.""")
  elseif key == "PhD"
    @test compareBibtexEntries(entry, raw"""
F.~M. Last, {\em This is a title.}
\newblock Type, School, Address, mm yyyy.
\newblock This is a note.""")
  elseif key == "Proceedings1"
    @test compareBibtexEntries(entry, raw"""
E.~E. ELast1, E.~E. ELast2, and E.~E. ELast3, eds., {\em This is a title.},
  vol.~v123 of {\em Series}, (Address), Organization, Publisher, mm yyyy.
\newblock This is a note.""")
  elseif key == "Proceedings2"
    @test compareBibtexEntries(entry, raw"""
E.~E. ELast1, E.~E. ELast2, and E.~E. ELast3, eds., {\em This is a title.},
  no.~n234 in Series, (Address), Organization, Publisher, mm yyyy.
\newblock This is a note.""")
  elseif key == "TechReport"
    @test compareBibtexEntries(entry, raw"""
F.~M. Last1, F.~M. Last2, and F.~M. Last3, ``This is a title.,'' Type n234,
  Institution, Address, mm yyyy.
\newblock This is a note.""")
  elseif key == "Unpubished"
    @test compareBibtexEntries(entry, raw"""
F.~M. Last1, F.~M. Last2, and F.~M. Last3, ``This is a title..'' This is a
  note, mm yyyy.""")
  elseif key == "Misc"
    @test compareBibtexEntries(entry, raw"""
F.~M. Last1, F.~M. Last2, and F.~M. Last3, ``This is a title..'' How it is
  published, mm yyyy.
\newblock This is a note.""")
  end
end

function testLibrary(entries::AbstractDict{String,E}) where E
  for (key, entry) in entries
    testEntry(key, format(entry, style = :ieeetr, fmt = :latex))
  end
end

end # module IeeetrTest

# -----------------------------------------------------------------

IeeetrTest.testLibrary(bibFile)
