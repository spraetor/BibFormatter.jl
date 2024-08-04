
struct Siam <: BibliographyStyle end

module BibliographyStyleSiam 

import BibInternal

empty(str::AbstractString)::Bool = isempty(str)
empty(arr::AbstractVector{T})::Bool where T = length(arr) > 0
fieldOrNull(field)::String = empty(field) ? "" : field

emphasize(fmt::OutputFormat, str::AbstractString) = empty(str) ? "" : outputEmph(fmt, str)
scapify(fmt::OutputFormat, str::AbstractString) = empty(str) ? "" : outputSmallCaps(fmt, str)
dashify(fmt::OutputFormat, str::AbstractString)::String = empty(str) ? "" : outputNumberRange(fmt,split(str,'-'))


function formatNames(fmt::OutputFormat, names::BibInternal.Names)::String
  out = ""
  numnames = length(names)
  for (i,n) in numerate(names)
    t = formatAuthorFLast(fmt, n.particle,n.last,n.junior,n.first,n.middle) # {f.~}{vv~}{ll}{, jj}
    if i > 1
      if numnames-i > 0     # namesleft > 1
        out *= ", " * t
      else
        if numnames > 2
          out *= ","
          if t == "others"
            out *= " " * outputJoinSpace(fmt, ["et","al."]) # et~al.
          else
            out *= " and " * t
          end
        end
      end
    else
      out = t
    end
  end
  out
end

function formatAuthors(fmt::OutputFormat, names::BibInternal.Names)::String
  empty(names) ? "" : scapify(fmt,formatNames(fmt,names))
end

function formatOrganization(fmt::OutputFormat, org::AbstractString)::String
  scapify(fmt,org)
end

function formatEditors(fmt::OutputFormat, names::BibInternal.Names)::String 
  empty(names) ? "" : scapify(fmt,formatNames(fmt,names)) * (length(names) > 1 ? ", eds." : ", ed.")
end

function formatIneditors(fmt::OutputFormat, names::BibInternal.Names)::String 
  empty(names) ? "" : formatNames(fmt,names) * (length(names) > 1 ? ", eds." : ", ed.")
end

function formatTitle(fmt::OutputFormat, title::AbstractString)::String
  empty(title) ? "" : emphasize(fmt, uppercasefirst(title))
end

function formatBTitle(fmt::OutputFormat, title::AbstractString)::String
  emphasize(fmt, title)
end

function formatDate(fmt::OutputFormat, date::BibInternal.Date)::String
  if empty(date.year)
    if empty(date.month)
      return ""
    else
      @warn "There's a month but not year"
    end
  else
    return empty(date.month) ? year : month * " " * year
  end
end

function formatBVolume(fmt::OutputFormat, data::BibInternal.In)::String
  if empty(data.volume) 
    return ""
  else
    out = outputJoinSpace(fmt,["vol.",data.volume])
    if !empty(data.series)
      out *= " of " * series
    end
    if !empty(data.number)
      @warn "Can't use both volume and number"
    end
    return out
  end
end

function formatNumberSeries(fmt::OutputFormat, data::BibInternal.In)::String
  if !empty(data.volume)
    return "" # Can't use both volume and number
  else
    if empty(data.number)
      return data.series
    else
      out = outputJoinSpace(fmt, ["no.",data.number])
      if empty(data.series)
        @warn "There's a number but no series"
      else
        out *= " in " * data.series
      end
      return out
    end
  end
end

function formatEdition(fmt::OutputFormat, edition::AbstractString)::String
  empty(edition) ? "" : outputJoinSpace(fmt, [lowercase(edition),"ed."])
end

function formatPages(fmt::OutputFormat, pages::AbstractString)::String
  empty(pages) ? 
    "" : 
    length(split(pages,r"[-,]")) > 1 ? 
      outputJoinSpace(fmt,["pp.",dashify(fmt,pages)]) : 
      outputJoinSpace(fmt,["p.",pages])
end

function FormatVolYear(fmt::OutputFormat, volume::AbstractString, year::AbstractString)::String
  out = volume
  if empty(year)
    @warn "Empty year"
  else
    out *= " ($year)"
  end
  out
end

formatAuthor(fmt::OutputFormat, style::Siam, von, last, junior, first, second)::String = formatAuthorFLast(fmt, von, last, junior, first, second)



formatAuthor(fmt::OutputFormat, style::Siam, von, last, junior, first, second)::String = formatAuthorFLast(fmt, von, last, junior, first, second)

formatVolume(fmt::OutputFormat, style::Siam, volume::AbstractString) = outputJoinSpace(fmt,["vol.",volume])
formatNumber(fmt::OutputFormat, style::Siam, volume::AbstractString) = outputJoinSpace(fmt,["no.",volume])
formatPages(fmt::OutputFormat, style::Siam, pages::AbstractString) = !isempty(pages) ? outputJoinSpace(fmt,["pp.",outputNumberRange(fmt,split(pages,'-'))]) : ""
formatEdition(fmt::OutputFormat, style::Siam, edition::AbstractString) = !isempty(edition) ? outputJoinSpace(fmt,[lowercase(edition),"ed."]) : ""

formatEditors(style::Siam, editors::AbstractString)::String = joinNotEmpty(editors,", ",isMultipleAuthors(editors) ? "eds." : "ed.")

formatChapter(style::Siam, chapter::AbstractString, type::AbstractString)::String = joinNotEmpty(isempty(type) ? "chapter" : lowercase(type), " ", chapter)






end # module BibliographyStyleStyleSiam



# F.~S. von Last, Junior, F.~M. Last2, and F.~M. Last3, ``Title,'' {\em Journal}, vol.~v123, pp.~1--2, mm yyyy.
# This is a note.
function formatArticle(fmt::OutputFormat, style::Siam, authors, title, journal, year; volume="", number="", pages="", month="", note="")
  BibliographyStyleSiam.article(fmt, authors, title, journal, year, volume, number, pages, month, note)
end

# F.~M. Last1, F.~M. Last2, and F.~M. Last3, {\em Title}, vol.~v123 of {\em Series}.
# Address: Publisher, edition~ed., mm yyyy.
# This is a note.
function formatBook(fmt::OutputFormat, style::Siam, title, publisher, year; authors="", editors="", volume="", number="", series="", address="", edition="", month="", note="")
  BibliographyStyleSiam.book(fmt, title, publisher, year, authors, editors, volume, number, series, address, edition, month, note)
end

# F.~M. Last1, F.~M. Last2, and F.~M. Last3, ``Title.'' How it is published, Address, mm yyyy.
# This is a note.
function formatBooklet(fmt::OutputFormat, style::Siam, title; authors="", howpublished="", address="", month="", year="", note="")
  BibliographyStyleSiam.booklet(fmt, title, authors, howpublished, address, month, year, note)
end

# F.~M. Last1, F.~M. Last2, and F.~M. Last3, {\em This is a title}, vol.~v123 of {\em Series}, type Chapter, pp.~1--2.
# Address: Publisher, edition~ed., mm yyyy.
# This is a note.
function formatInbook(fmt::OutputFormat, style::Siam, title, chapter, publisher, year; authors="", editors="", volume="", number="", series="", type="", address="", edition="", month="", pages="", note="")
  BibliographyStyleSiam.inbook(fmt, title, chapter, publisher, year, authors, editors, volume, number, series, type, address, edition, month, pages, note)
end

# F.~M. Last1, F.~M. Last2, and F.~M. Last3, ``Title,'' in {\em Booktitle} (E.~E. ELast1, E.~E. ELast2, and E.~E. ELast3, eds.), vol.~v123 of {\em Series}, type Chapter, pp.~1--2, Address: Publisher, edition~ed., mm yyyy.
# This is a note.
function formatInCollection(fmt::OutputFormat, style::Siam, authors, title, booktitle, publisher, year; editors="", volume="", number="", series="", type="", chapter="", pages="", address="", edition="", month="", note="")
  BibliographyStyleSiam.incollection(fmt, authors, title, booktitle, publisher, year, editors, volume, number, series, type, chapter, pages, address, edition, month, note)
end

# F.~M. Last1, F.~M. Last2, and F.~M. Last3, {\em Title}.
# Organization, Address, edition~ed., mm yyyy.
# This is a note.
function formatManual(fmt::OutputFormat, style::Siam, title, year; authors="", organization="", address="", edition="", month="", note="")
  BibliographyStyleSiam.manual(fmt, title, year, authors, organization, address, edition, month, note)
end

# F.~M. Last, ``Title,'' type, School, Address, mm yyyy.
# This is a note.
function formatMastersThesis(fmt::OutputFormat, style::Siam, author, title, school, year; type="", address="", month="", note="")
  BibliographyStyleSiam.mastersthesis(fmt, author, title, school, year, type, address, month, note)
end

# F.~M. Last1, F.~M. Last2, and F.~M. Last3, ``Title.'' How it is published, mm yyyy.
# This is a note.
function formatMisc(fmt::OutputFormat, style::Siam; authors="", title="", howpublished="", month="", year="", note="")
  BibliographyStyleSiam.misc(fmt, authors, title, howpublished, month, year, note)
end

# F.~M. Last, {\em Title}.
# Type, School, Address, mm yyyy.
# This is a note.
function formatPhDThesis(fmt::OutputFormat, style::Siam, author, title, school, year; type="", address="", month="", note="")
  BibliographyStyleSiam.phdthesis(fmt, author, title, school, year, type, address, month, note)
end

# E.~E. ELast1, E.~E. ELast2, and E.~E. ELast3, eds., {\em Title}, vol.~v123 of {\em Series}, (Address), Organization, Publisher, mm yyyy.
# This is a note.
function formatProceedings(fmt::OutputFormat, style::Siam, title, year; editors="", volume="", number="", series="", organization="", address="", month="", publisher="", note="")
  BibliographyStyleSiam.proceedings(fmt, title, year, editors, volume, number, series, organization, address, month, publisher, note)
end

# F.~M. Last1, F.~M. Last2, and F.~M. Last3, ``Title,'' Type n234, Institution, Address, mm yyyy.
# This is a note.
function formatTechreport(fmt::OutputFormat, style::Siam, authors, title, institution, year; type="", number="", address="", month="", note="")
  BibliographyStyleSiam.techreport(fmt, authors, title, institution, year, type, number, address, month, note)
end

# F.~M. Last1, F.~M. Last2, and F.~M. Last3, ``Title.'' This is a note, mm yyyy.
function formatUnpublished(fmt::OutputFormat, style::Siam, authors, title, note; howpublished="", month="", year="")
  BibliographyStyleSiam.pubpublished(fmt, authors, title, note, howpublished, month, year)
end