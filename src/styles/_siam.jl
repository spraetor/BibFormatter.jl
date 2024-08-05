
struct Siam <: BibliographyStyle end

module BibliographyStyleSiam

using ...BibFormatter: OutputFormat, outputEmph, outputSmallCaps, outputNumberRange, outputJoinSpace, formatAuthorFLast
import BibInternal

empty(str::AbstractString) = isempty(str)
empty(arr::AbstractVector{T}) where T = length(arr) == 0
empty(data::BibInternal.Entry, key::Symbol) = !hasproperty(data,key) || empty(getproperty(data,key)::String)
fieldOrNull(field) = empty(field) ? "" : field

emphasize(fmt::OutputFormat, str::AbstractString) = empty(str) ? "" : outputEmph(fmt, str)
scapify(fmt::OutputFormat, str::AbstractString) = empty(str) ? "" : outputSmallCaps(fmt, str)
dashify(fmt::OutputFormat, str::AbstractString) = empty(str) ? "" : outputNumberRange(fmt,split(str,'-'))
tieConnect(fmt::OutputFormat, arr::AbstractVector{T}) where T = outputJoinSpace(fmt,arr)
tieOrSpaceConnect(fmt::OutputFormat, arr::AbstractVector{T}) where T = length(arr[end]) > 3 ? tieConnect(fmt,arr) : join(arr," ")


function outputCheck!(arr::AbstractVector{T}, str::AbstractString, msg::AbstractString) where T
  if empty(str)
    @warn msg
  else
    push!(arr, str)
  end
end

function output!(arr::AbstractVector{T}, str::AbstractString) where T
  !empty(str) && push!(arr, str)
end

function outputNotNull!(arr::AbstractVector{T}, str::AbstractString) where T
  @assert !empty(str)
  push!(arr, str)
end


function formatNames(fmt::OutputFormat, names::BibInternal.Names)::String
  out = ""
  numnames = length(names)
  for (i,n) in enumerate(names)
    t = formatAuthorFLast(fmt, n.particle,n.last,n.junior,n.first,n.middle) # {f.~}{vv~}{ll}{, jj}
    if i > 1
      if numnames-i > 0     # namesleft > 1
        out *= ", " * t
      else
        if numnames > 2
          out *= ","
          if t == "others"
            out *= " " * tieConnect(fmt, ["et","al."]) # et~al.
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

"Format author names in small caps"
function formatAuthors(fmt::OutputFormat, names::BibInternal.Names)::String
  if empty(names)
    @warn "Names are empty: $(names)"
  end
  empty(names) ? "" : scapify(fmt,formatNames(fmt,names))
end

"Format organization in small caps"
function formatOrganization(fmt::OutputFormat, org::AbstractString)::String
  scapify(fmt,org)
end

"Format editor names in small caps, postfixed by 'ed(s).'"
function formatEditors(fmt::OutputFormat, names::BibInternal.Names)::String
  empty(names) ? "" : scapify(fmt,formatNames(fmt,names)) * (length(names) > 1 ? ", eds." : ", ed.")
end

"Form editor names with postfixed by 'ed(s).'"
function formatIneditors(fmt::OutputFormat, names::BibInternal.Names)::String
  empty(names) ? "" : formatNames(fmt,names) * (length(names) > 1 ? ", eds." : ", ed.")
end

"Emphasize the title and convert it into sentence-case."
function formatTitle(fmt::OutputFormat, title::AbstractString)::String
  empty(title) ? "" : emphasize(fmt, uppercasefirst(lowercase(title)))
end

"Emphasize the title."
function formatBTitle(fmt::OutputFormat, title::AbstractString)::String
  emphasize(fmt, title)
end

"Format the dat as '[mm ]yyyy'."
function formatDate(fmt::OutputFormat, data::BibInternal.Entry)::String
  if empty(data.date.year)
    if empty(data.date.month)
      return ""
    else
      @warn "There's a month but not year in $(data.id)"
    end
  else
    return empty(data.date.month) ? data.date.year : data.date.month * " " * data.date.year
  end
end

"Format 'vol.~volume of series'."
function formatBVolume(fmt::OutputFormat, data::BibInternal.Entry)::String
  if empty(data.in.volume)
    return ""
  else
    out = tieConnect(fmt,["vol.",data.in.volume])
    if !empty(data.in.series)
      out *= " of " * data.in.series
    end
    if !empty(data.in.number)
      @warn "Can't use both volume and number in $(data.id)"
    end
    return out
  end
end

"Format 'no.~number in series'."
function formatNumberSeries(fmt::OutputFormat, data::BibInternal.Entry)::String
  if !empty(data.in.volume)
    return "" # Can't use both volume and number
  else
    if empty(data.in.number)
      return data.in.series
    else
      out = tieConnect(fmt, ["no.",data.in.number])
      if empty(data.in.series)
        @warn "There's a number but no series in $(data.id)"
      else
        out *= " in " * data.in.series
      end
      return out
    end
  end
end

"Format edition postfixed by 'ed.'."
function formatEdition(fmt::OutputFormat, data::BibInternal.Entry)::String
  empty(data.in.edition) ? "" : tieConnect(fmt, [lowercase(data.in.edition),"ed."])
end

"Format pages as 'pp.~1--2' or 'p.~1."
function formatPages(fmt::OutputFormat, data::BibInternal.Entry)::String
  if empty(data.in.pages)
    return ""
  else
    return length(split(data.in.pages,r"[-,]")) > 1 ?
      tieConnect(fmt,["pp.",dashify(fmt,data.in.pages)]) :
      tieConnect(fmt,["p.",data.in.pages])
  end
end

"Format as 'volume (year)'."
function formatVolYear(fmt::OutputFormat, data::BibInternal.Entry)::String
  out = data.in.volume
  if empty(data.date.year)
    @warn "Empty 'year' in $(data.id)."
  else
    out *= " ($(data.date.year))"
  end
  out
end

"Format chaper and pages as 'ch.~chapter, pp.~1--2'."
function formatChapterPages(fmt::OutputFormat, data::BibInternal.Entry)::String
  if empty(data.in.chapter)
    return formatPages(fmt,data)
  else
    out = empty(data,:type) ?
      tieConnect(fmt,["ch.",chapter]) :
      tieOrSpaceConnect(fmt,[lowercase(data.type),chapter])

    if !empty(data.in.pages)
      out *= ", " * formatPages(fmt,data)
    end
    return out
  end
end

"Formate booktitle as 'in booktitle[, editors...]'."
function formatInEdBooktitle(fmt::OutputFormat, data::BibInternal.Entry)::String
  if empty(data.booktitle)
    return ""
  else
    return empty(data.editors) ?
      "in " * data.booktitle :
      "in " * data.booktitle * ", " * formatInEditors(fmt,data)
  end
end

"Check if all relevant fields for the misc type are empty."
function emptyMiscCheck(data::BibInternal.Entry)::Bool
  if empty(data.authors) && empty(data.title) && empty(data.access.howpublished) &&
     empty(data.date.month) && empty(data.date.year) && haskey(data.fields,"note")
     @warn "All relevant fields are empty in $(data.id)."
    return false
  else
    return true
  end
end

"Transform the thesis type into lowercase if set."
function formatThesisType(fmt::OutputFormat, data::BibInternal.Entry)::String
  empty(data,:type) ? "" : lowercase(data.type)
end

"Format the tech report number as 'Tech. Rep.~number' or 'type~number'"
function formatTrNumber(fmt::OutputFormat, data::BibInternal.Entry)::String
  out = empty(data,:type) ? "Tech. Rep." : data.type
  empty(data.in.number) ? lowercase(out) : tieOrSpaceConnect(out,data.in.number)
end

# TODO: crossref not implemented

function article(fmt::OutputFormat, data::BibInternal.Entry)
  blocks = []

  output!(blocks, let list = []
    outputCheck!(list, formatAuthors(fmt,data.authors), "Empty 'author' in $(data.id).")
    outputCheck!(list, formatTitle(fmt,data.title), "Empty 'title' in $(data.id).")
    outputCheck!(list, data.in.journal, "Empty 'journal' in $(data.id).")
    output!(list, formatVolYear(fmt,data))
    output!(list, formatPages(fmt,data))

    join(list, ", ")
  end)

  output!(blocks, get(data.fields,"note",""))
  blocks
end

function book(fmt::OutputFormat, data::BibInternal.Entry)
  blocks = []

  output!(blocks, let list = []
    if empty(data.authors)
      outputCheck!(list, formatEditors(fmt,data.editors), "Empty 'author' and 'editor' in $(data.id).")
    else
      push!(list, formatAuthors(fmt,data.authors))
      if !empty(data.editors)
        @warn "Can't use both 'author' and 'editor' fields in $(data.id)"
      end
    end

    outputCheck!(list, formatBTitle(fmt, data.title), "Empty 'title' in $(data.id).")
    output!(list, formatBVolume(fmt,data))
    output!(list, formatNumberSeries(fmt,data))
    outputCheck!(list, data.in.publisher, "Empty 'publisher' in $(data.in).")
    output!(list, data.in.address)
    output!(list, formatEdition(fmt,data))
    outputCheck!(list, formatDate(fmt,data), "Empty 'year' in $(data.in).")

    join(list, ", ")
  end)

  output!(blocks, get(data.fields,"note",""))
  blocks
end

end # module BibliographyStyleStyleSiam



# F.~S. von Last, Junior, F.~M. Last2, and F.~M. Last3, ``Title,'' {\em Journal}, vol.~v123, pp.~1--2, mm yyyy.
# This is a note.
function formatArticle(fmt::OutputFormat, style::Siam, data::BibInternal.Entry)
  BibliographyStyleSiam.article(fmt, data)
end

# F.~M. Last1, F.~M. Last2, and F.~M. Last3, {\em Title}, vol.~v123 of {\em Series}.
# Address: Publisher, edition~ed., mm yyyy.
# This is a note.
function formatBook(fmt::OutputFormat, style::Siam, data::BibInternal.Entry)
  BibliographyStyleSiam.book(fmt, data)
end

# F.~M. Last1, F.~M. Last2, and F.~M. Last3, ``Title.'' How it is published, Address, mm yyyy.
# This is a note.
#function formatBooklet(fmt::OutputFormat, style::Siam, data::BibInternal.Entry)
#  BibliographyStyleSiam.booklet(fmt, data)
#end

# F.~M. Last1, F.~M. Last2, and F.~M. Last3, {\em This is a title}, vol.~v123 of {\em Series}, type Chapter, pp.~1--2.
# Address: Publisher, edition~ed., mm yyyy.
# This is a note.
#function formatInBook(fmt::OutputFormat, data::BibInternal.Entry)
#  BibliographyStyleSiam.inbook(fmt, data)
#end

# F.~M. Last1, F.~M. Last2, and F.~M. Last3, ``Title,'' in {\em Booktitle} (E.~E. ELast1, E.~E. ELast2, and E.~E. ELast3, eds.), vol.~v123 of {\em Series}, type Chapter, pp.~1--2, Address: Publisher, edition~ed., mm yyyy.
# This is a note.
#function formatInCollection(fmt::OutputFormat, style::Siam, data::BibInternal.Entry)
#  BibliographyStyleSiam.incollection(fmt, data)
#end

# F.~M. Last1, F.~M. Last2, and F.~M. Last3, {\em Title}.
# Organization, Address, edition~ed., mm yyyy.
# This is a note.
#function formatManual(fmt::OutputFormat, style::Siam, data::BibInternal.Entry)
#  BibliographyStyleSiam.manual(fmt, data)
#end

# F.~M. Last, ``Title,'' type, School, Address, mm yyyy.
# This is a note.
#function formatMastersThesis(fmt::OutputFormat, style::Siam, data::BibInternal.Entry)
#  BibliographyStyleSiam.mastersthesis(fmt, data)
#end

# F.~M. Last1, F.~M. Last2, and F.~M. Last3, ``Title.'' How it is published, mm yyyy.
# This is a note.
#function formatMisc(fmt::OutputFormat, style::Siam; data::BibInternal.Entry)
#  BibliographyStyleSiam.misc(fmt, data)
#end

# F.~M. Last, {\em Title}.
# Type, School, Address, mm yyyy.
# This is a note.
#function formatPhDThesis(fmt::OutputFormat, style::Siam, data::BibInternal.Entry)
#  BibliographyStyleSiam.phdthesis(fmt, data)
#end

# E.~E. ELast1, E.~E. ELast2, and E.~E. ELast3, eds., {\em Title}, vol.~v123 of {\em Series}, (Address), Organization, Publisher, mm yyyy.
# This is a note.
#function formatProceedings(fmt::OutputFormat, style::Siam, data::BibInternal.Entry)
#  BibliographyStyleSiam.proceedings(fmt, data)
#end

# F.~M. Last1, F.~M. Last2, and F.~M. Last3, ``Title,'' Type n234, Institution, Address, mm yyyy.
# This is a note.
#function formatTechreport(fmt::OutputFormat, style::Siam, data::BibInternal.Entry)
#  BibliographyStyleSiam.techreport(fmt, data)
#end

# F.~M. Last1, F.~M. Last2, and F.~M. Last3, ``Title.'' This is a note, mm yyyy.
#function formatUnpublished(fmt::OutputFormat, style::Siam, data::BibInternal.Entry)
#  BibliographyStyleSiam.pubpublished(fmt, data)
#end