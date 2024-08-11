
struct Siam <: BibliographyStyle end

module BibliographyStyleSiam

using ...BibFormatter: OutputFormat, formatAuthorFLast
using ..BibliographyStyleCommon: empty, emphasize, scapify, dashify, tieConnect, tieOrSpaceConnect, replaceMonth, formatNamesFLast
import BibInternal

function outputCheck!(arr::AbstractVector{T}, str::AbstractString, msg::AbstractString) where T
  if empty(str)
    @warn msg
  else
    push!(arr, str)
  end
end

output!(arr::AbstractVector{T}, str::AbstractString) where T = !empty(str) && push!(arr, str)

function outputNonNull!(arr::AbstractVector{T}, str::AbstractString) where T
  @assert !empty(str)
  push!(arr, str)
end

const journalAbbrv = Dict(
  "acmcs" => "ACM Comput. Surveys",
  "acta" => "Acta Inf.",
  "cacm" => "Comm. ACM",
  "ibmjrd" => "IBM J. Res. Dev.",
  "ibmsj" => "IBM Syst.~J.",
  "ieeese" => "IEEE Trans. Softw. Eng.",
  "ieeetc" => "IEEE Trans. Comput.",
  "ieeetcad" => "IEEE Trans. Comput.-Aided Design Integrated Circuits",
  "ipl" => "Inf. Process. Lett.",
  "jacm" => "J.~Assoc. Comput. Mach.",
  "jcss" => "J.~Comput. System Sci.",
  "scp" => "Sci. Comput. Programming",
  "sicomp" => "SIAM J. Comput.",
  "tocs" => "ACM Trans. Comput. Syst.",
  "tods" => "ACM Trans. Database Syst.",
  "tog" => "ACM Trans. Gr.",
  "toms" => "ACM Trans. Math. Softw.",
  "toois" => "ACM Trans. Office Inf. Syst.",
  "toplas" => "ACM Trans. Prog. Lang. Syst.",
  "tcs" => "Theoretical Comput. Sci.",
)

replaceJournal(str::String) = empty(str) ? "" : get(journalAbbrv, str, str)

formatNames(fmt::OutputFormat, names::BibInternal.Names)::String = formatNamesFLast(fmt, names)

"Format author names in small caps"
function formatAuthors(fmt::OutputFormat, data::BibInternal.Entry)::String
  empty(data.authors) ? "" : scapify(fmt,formatNames(fmt,data.authors))
end

"Format organization in small caps"
function formatOrganization(fmt::OutputFormat, data::BibInternal.Entry)::String
  scapify(fmt,data.in.organization)
end

"Format editor names in small caps, postfixed by 'ed(s).'"
function formatEditors(fmt::OutputFormat, data::BibInternal.Entry)::String
  empty(data.editors) ? "" : scapify(fmt,formatNames(fmt,data.editors)) * (length(data.editors) > 1 ? ", eds." : ", ed.")
end

"Form editor names with postfixed by 'ed(s).'"
function formatInEditors(fmt::OutputFormat, data::BibInternal.Entry)::String
  empty(data.editors) ? "" : formatNames(fmt,data.editors) * (length(data.editors) > 1 ? ", eds." : ", ed.")
end

"Emphasize the title and convert it into sentence-case."
function formatTitle(fmt::OutputFormat, data::BibInternal.Entry)::String
  empty(data.title) ? "" : emphasize(fmt, uppercasefirst(lowercase(data.title)))
end

"Emphasize the title."
function formatBTitle(fmt::OutputFormat, data::BibInternal.Entry)::String
  emphasize(fmt, data.title)
end

"Format the dat as '[mm ]yyyy'."
function formatDate(fmt::OutputFormat, data::BibInternal.Entry)::String
  if empty(data.date.year)
    if empty(data.date.month)
      return ""
    else
      @warn "There's a 'month' but not 'year' in $(data.id)"
    end
  else
    return empty(data.date.month) ? data.date.year : replaceMonth(data.date.month) * " " * data.date.year
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
      @warn "Can't use both 'volume' and 'number' in $(data.id)"
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
        @warn "There's a 'number' but no 'series' in $(data.id)"
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
    out = empty(data.fields,"type") ?
      tieConnect(fmt,["ch.",data.in.chapter]) :
      tieOrSpaceConnect(fmt,[lowercase(data.fields["type"]),data.in.chapter])

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
      "in " * data.booktitle * ", " * formatInEditors(fmt, data)
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
function formatThesisType(fmt::OutputFormat, data::BibInternal.Entry, tite::String)::String
  empty(data.fields,"type") ? title : lowercase(data.fields["type"])
end

"Format the tech report number as 'Tech. Rep.~number' or 'type~number'"
function formatTrNumber(fmt::OutputFormat, data::BibInternal.Entry)::String
  out = empty(data.fields,"type") ? "Tech. Rep." : data.fields["type"]
  empty(data.in.number) ? lowercase(out) : tieOrSpaceConnect(fmt,[out,data.in.number])
end

# TODO: crossref not implemented

function article(fmt::OutputFormat, data::BibInternal.Entry)
  blocks = let list = []
    outputCheck!(list, formatAuthors(fmt, data), "Empty 'author' in $(data.id).")
    outputCheck!(list, formatTitle(fmt, data), "Empty 'title' in $(data.id).")
    outputCheck!(list, replaceJournal(data.in.journal), "Empty 'journal' in $(data.id).")
    output!(list, formatVolYear(fmt, data))
    output!(list, formatPages(fmt, data))

    [join(list, ", ")]
  end

  output!(blocks, get(data.fields,"note",""))
  blocks
end

function book(fmt::OutputFormat, data::BibInternal.Entry)
  blocks = let list = []
    if empty(data.authors)
      outputCheck!(list, formatEditors(fmt, data), "Empty 'author' and 'editor' in $(data.id).")
    else
      push!(list, formatAuthors(fmt, data))
      if !empty(data.editors)
        @warn "Can't use both 'author' and 'editor' fields in $(data.id)"
      end
    end

    outputCheck!(list, formatBTitle(fmt, data), "Empty 'title' in $(data.id).")
    output!(list, formatBVolume(fmt,data))
    output!(list, formatNumberSeries(fmt,data))
    outputCheck!(list, data.in.publisher, "Empty 'publisher' in $(data.id).")
    output!(list, data.in.address)
    output!(list, formatEdition(fmt,data))
    outputCheck!(list, formatDate(fmt,data), "Empty 'year' in $(data.id).")

    [join(list, ", ")]
  end

  output!(blocks, get(data.fields,"note",""))
  blocks
end

function booklet(fmt::OutputFormat, data::BibInternal.Entry)
  blocks = let list1 = [], list2 = []
    output!(list1, formatAuthors(fmt, data))
    outputCheck!(list1, formatTitle(fmt, data), "Empty 'title' in $(data.id)")

    output!(list2, data.access.howpublished)
    output!(list2, data.in.address)
    output!(list2, formatDate(fmt, data))

    empty(data.access.howpublished) ?
      [join([list1;list2], ", ")] :
      [join(list1, ", "), join(list2, ", ")]
  end

  output!(blocks, get(data.fields,"note",""))
  blocks
end

function inbook(fmt::OutputFormat, data::BibInternal.Entry)
  blocks = let list = []
    if empty(data.authors)
      outputCheck!(list, formatEditors(fmt, data), "Empty 'author' and 'editor' in $(data.id)")
    else
      output!(list, formatAuthors(fmt, data))
      if !empty(data.editors)
        @warn "Can't use both 'author' and 'editor' fields in $(data.id)"
      end
    end

    outputCheck!(list, formatBTitle(fmt, data), "Empty 'title' in $(data.id)")
    output!(list, formatBVolume(fmt, data))
    output!(list, formatNumberSeries(fmt, data))
    outputCheck!(list, data.in.publisher, "Empty 'publisher' in $(data.id)")
    output!(list, data.in.address)
    output!(list, formatEdition(fmt, data))
    outputCheck!(list, formatDate(fmt, data), "Empty 'year' in $(data.id)")
    outputCheck!(list, formatChapterPages(fmt, data), "Empty 'chapter' and 'pages' in $(data.id)")
    [join(list, ", ")]
  end

  output!(blocks, get(data.fields,"note",""))
  blocks
end


function incollection(fmt::OutputFormat, data::BibInternal.Entry)
  blocks = let list = []
    outputCheck!(list, formatAuthors(fmt, data), "Empty 'author' in $(data.id)")
    outputCheck!(list, formatTitle(fmt, data), "Empty 'title' in $(data.id)")
    outputCheck!(list, formatInEdBooktitle(fmt, data), "Empty 'booktitle' in $(data.id)")
    output!(list, formatBVolume(fmt, data))
    output!(list, formatNumberSeries(fmt, data))
    outputCheck!(list, data.in.publisher, "Empty 'publisher' in $(data.id)")
    output!(list, data.in.address)
    output!(list, formatEdition(fmt, data))
    outputCheck!(list, formatDate(fmt, data), "Empty 'year' in $(data.id)")
    output!(list, formatChapterPages(fmt, data))
    [join(list, ", ")]
  end

  output!(blocks, get(data.fields,"note",""))
  blocks
end


function inproceedings(fmt::OutputFormat, data::BibInternal.Entry)
  blocks = let list = []
    outputCheck!(list, formatAuthors(fmt, data), "Empty 'author' in $(data.id)")
    outputCheck!(list, formatTitle(fmt, data), "Empty 'title' in $(data.id)")
    outputCheck!(list, formatInEdBooktitle(fmt, data), "Empty 'booktitle' in $(data.id)")
    output!(list, formatBVolume(fmt, data))
    output!(list, formatNumberSeries(fmt, data))

    if empty(data.in.address)
      output!(list, data.in.organization)
      output!(list, data.in.publisher)
      outputCheck!(list, formatDate(fmt, data), "Empty 'year' in $(data.id)")
    else
      outputNonNull!(list, data.in.address)
      outputCheck!(list, formatDate(fmt, data), "Empty 'year' in $(data.id)")
      output!(list, data.in.organization)
      output!(list, data.in.publisher)
    end

    output!(list, formatPages(fmt, data))
    [join(list, ", ")]
  end

  output!(blocks, get(data.fields,"note",""))
  blocks
end


conference(fmt::OutputFormat, data::BibInternal.Entry) = inproceedings(fmt, data)


function manual(fmt::OutputFormat, data::BibInternal.Entry)
  blocks = let list = []
    if empty(data.authors)
      output!(list, formatOrganization(fmt, data))
    else
      outputNonNull!(list, formatAuthors(fmt, data))
    end
    outputCheck!(list, formatBTitle(fmt, data), "Empty 'title' in $(data.id)")
    if !empty(data.authors)
      output!(list, data.in.organization)
    end
    output!(list, data.in.address)
    output!(list, formatEdition(fmt, data))
    output!(list, formatDate(fmt, data))
    [join(list, ", ")]
  end

  output!(blocks, get(data.fields,"note",""))
  blocks
end

function mastersthesis(fmt::OutputFormat, data::BibInternal.Entry)
  blocks = let list = []
    outputCheck!(list, formatAuthors(fmt, data), "Empty 'author' in $(data.id)")
    outputCheck!(list, formatTitle(fmt, data), "Empty 'title' in $(data.id)")
    outputNonNull!(list, formatThesisType(fmt, data, "Master's thesis"))
    outputCheck!(list, data.in.school, "Empty 'school' in $(data.id)")
    output!(list, data.in.address)
    outputCheck!(list, formatDate(fmt, data), "Empty 'year' in $(data.id)")
    [join(list, ", ")]
  end

  output!(blocks, get(data.fields,"note",""))
  blocks
end

function misc(fmt::OutputFormat, data::BibInternal.Entry)
  blocks = let list1 = [], list2 = []
    output!(list1, formatAuthors(fmt, data))
    output!(list1, formatTitle(fmt, data))

    output!(list2, data.access.howpublished)
    output!(list2, formatDate(fmt, data))

    empty(data.access.howpublished) ?
      [join([list1;list2], ", ")] :
      [join(list1, ", "), join(list2, ", ")]
  end

  output!(blocks, get(data.fields,"note",""))
  emptyMiscCheck(data)
  blocks
end


function phdthesis(fmt::OutputFormat, data::BibInternal.Entry)
  blocks = let list = []
    outputCheck!(list, formatAuthors(fmt, data), "Empty 'author' in $(data.id)")
    outputCheck!(list, formatBTitle(fmt, data), "Empty 'title' in $(data.id)")
    outputNonNull!(list, formatThesisType(fmt, data, "PhD thesis"))
    outputCheck!(list, data.in.school, "Empty 'school' in $(data.id)")
    output!(list, data.in.address)
    outputCheck!(list, formatDate(fmt, data), "Empty 'year' in $(data.id)")
    [join(list, ", ")]
  end

  output!(blocks, get(data.fields,"note",""))
  blocks
end


function proceedings(fmt::OutputFormat, data::BibInternal.Entry)
  blocks = let list = []
    if empty(data.editors)
      output!(list, formatOrganization(fmt, data))
    else
      outputNonNull!(list, formatEditors(fmt, data))
    end
    outputCheck!(list, formatBTitle(fmt, data), "Empty 'title' in $(data.id)")
    output!(list, formatBVolume(fmt, data))
    output!(list, formatNumberSeries(fmt, data))
    if empty(data.in.address)
      if !empty(data.editors)
        output!(list, data.in.organization)
      end
      output!(list, data.in.publisher)
      outputCheck!(list, formatDate(fmt, data), "Empty 'year' in $(data.id)")
    else
      outputNonNull!(list, data.in.address)
      outputCheck!(list, formatDate(fmt, data), "Empty 'year' in $(data.id)")
      if !empty(data.editors)
        output!(list, data.in.organization)
      end
      output!(list, data.in.publisher)
    end
    [join(list, ", ")]
  end

  output!(blocks, get(data.fields,"note",""))
  blocks
end


function techreport(fmt::OutputFormat, data::BibInternal.Entry)
  blocks = let list = []
    outputCheck!(list, formatAuthors(fmt, data), "Empty 'author' in $(data.id)")
    outputCheck!(list, formatTitle(fmt, data), "Empty 'title' in $(data.id)")
    outputNonNull!(list, formatTrNumber(fmt, data))
    outputCheck!(list, data.in.institution, "Empty 'institution' in $(data.id)")
    output!(list, data.in.address)
    outputCheck!(list, formatDate(fmt, data), "Empty 'year' in $(data.id)")
    [join(list, ", ")]
  end

  output!(blocks, get(data.fields,"note",""))
  blocks
end


function unpublished(fmt::OutputFormat, data::BibInternal.Entry)
  blocks = let list = []
    outputCheck!(list, formatAuthors(fmt, data), "Empty 'author' in $(data.id)")
    outputCheck!(list, formatTitle(fmt, data), "Empty 'title' in $(data.id)")
    [join(list, ", ")]
  end

  outputCheck!(blocks, get(data.fields,"note",""), "Empty 'not' in $(data.id)")
  output!(blocks, formatDate(fmt, data))
  blocks
end


end # module BibliographyStyleStyleSiam



# {\sc F.~S. von Last, Junior, F.~M. Last2, and F.~M. Last3}, {\em Title}, Journal, v123 (yyyy), pp.~1--2.
# This is a note.
function formatArticle(fmt::OutputFormat, style::Siam, data::BibInternal.Entry)
  BibliographyStyleSiam.article(fmt, data)
end

# {\sc F.~M. Last1, F.~M. Last2, and F.~M. Last3}, {\em Title}, vol.~v123 of Series, Publisher, Address, edition~ed., mm yyyy.
# This is a note.
function formatBook(fmt::OutputFormat, style::Siam, data::BibInternal.Entry)
  BibliographyStyleSiam.book(fmt, data)
end

# {\sc F.~M. Last1, F.~M. Last2, and F.~M. Last3}, {\em Title}.
# How it is published, Address, mm yyyy.
# This is a note.
function formatBooklet(fmt::OutputFormat, style::Siam, data::BibInternal.Entry)
  BibliographyStyleSiam.booklet(fmt, data)
end

# {\sc F.~M. Last1, F.~M. Last2, and F.~M. Last3}, {\em This is a title}, vol.~v123 of Series, Publisher, Address, edition~ed., mm yyyy, type~Chapter, pp.~1--2.
# This is a note.
function formatInBook(fmt::OutputFormat, style::Siam, data::BibInternal.Entry)
  BibliographyStyleSiam.inbook(fmt, data)
end

# {\sc F.~M. Last1, F.~M. Last2, and F.~M. Last3}, {\em Title}, in Booktitle, E.~E. ELast1, E.~E. ELast2, and E.~E. ELast3, eds., vol.~v123 of Series, Publisher, Address, edition~ed., mm yyyy, type~Chapter, pp.~1--2.
# This is a note.
function formatInCollection(fmt::OutputFormat, style::Siam, data::BibInternal.Entry)
  BibliographyStyleSiam.incollection(fmt, data)
end

# {\sc F.~M. Last1, F.~M. Last2, and F.~M. Last3}, {\em Title}, Organization, Address, edition~ed., mm yyyy.
# This is a note.
function formatManual(fmt::OutputFormat, style::Siam, data::BibInternal.Entry)
  BibliographyStyleSiam.manual(fmt, data)
end

# {\sc F.~M. Last}, {\em Title}, type, School, Address, mm yyyy.
# This is a note.
function formatMastersThesis(fmt::OutputFormat, style::Siam, data::BibInternal.Entry)
  BibliographyStyleSiam.mastersthesis(fmt, data)
end

# {\sc F.~M. Last1, F.~M. Last2, and F.~M. Last3}, {\em Title}.
# How it is published, mm yyyy.
# This is a note.
function formatMisc(fmt::OutputFormat, style::Siam, data::BibInternal.Entry)
  BibliographyStyleSiam.misc(fmt, data)
end

# {\sc F.~M. Last}, {\em Title}, type, School, Address, mm yyyy.
# This is a note.
function formatPhDThesis(fmt::OutputFormat, style::Siam, data::BibInternal.Entry)
  BibliographyStyleSiam.phdthesis(fmt, data)
end

# {\sc E.~E. ELast1, E.~E. ELast2, and E.~E. ELast3}, eds., {\em Title}, vol.~v123 of Series, Address, mm yyyy, Organization, Publisher.
# \newblock This is a note.
function formatProceedings(fmt::OutputFormat, style::Siam, data::BibInternal.Entry)
  BibliographyStyleSiam.proceedings(fmt, data)
end

# {\sc F.~M. Last1, F.~M. Last2, and F.~M. Last3}, {\em Title}, Type~n234, Institution, Address, mm yyyy.
# This is a note.
function formatTechreport(fmt::OutputFormat, style::Siam, data::BibInternal.Entry)
  BibliographyStyleSiam.techreport(fmt, data)
end

# {\sc F.~M. Last1, F.~M. Last2, and F.~M. Last3}, {\em Title}.
# This is a note.
# Mm yyyy.
function formatUnpublished(fmt::OutputFormat, style::Siam, data::BibInternal.Entry)
  BibliographyStyleSiam.unpublished(fmt, data)
end