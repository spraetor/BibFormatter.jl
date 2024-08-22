
struct Siam <: BibliographyStyle end

module BibliographyStyleSiam

using ...BibFormatter: OutputFormat, formatAuthorFLast, outputAddPeriod
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


# ------------------------------------------------------------------------------

@enum OutputState begin
  BEFORE_ALL
  MID_SENTENCE
  AFTER_BLOCK
end

mutable struct Output
  blocks::Vector{String}
  sentence::String
  state::OutputState
  fmt::OutputFormat

  Output(fmt::OutputFormat) = new(String[], "", BEFORE_ALL, fmt)
end

function addPeriod!(out::Output)
  out.sentence = outputAddPeriod(out.fmt, out.sentence)
end

function outputNonNull!(out::Output, str::AbstractString)
  if out.state == MID_SENTENCE
    out.sentence *= ", " * str
  else
    if out.state == AFTER_BLOCK
      addPeriod!(out)
      push!(out.blocks, out.sentence)
    end
    out.sentence = str
    out.state = MID_SENTENCE
  end
end

function outputCheck!(out::Output, str::AbstractString, msg::AbstractString)
  if empty(str)
    @warn msg
  else
    outputNonNull!(out, str)
  end
end

output!(out::Output, str::AbstractString) = !empty(str) && outputNonNull!(out, str)

function finEntry!(out::Output)
  addPeriod!(out)
  push!(out.blocks, out.sentence)
  out.blocks
end

function newBlock!(out::Output)
  if out.state != BEFORE_ALL
    out.state = AFTER_BLOCK
  end
end

newBlockCheck!(out::Output, str::AbstractString) = !empty(str) && newBlock!(out)

# ------------------------------------------------------------------------------

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

formatNames(out::Output, names::BibInternal.Names)::String = formatNamesFLast(out.fmt, names)

"Format author names in small caps"
function formatAuthors(out::Output, data::BibInternal.Entry)::String
  empty(data.authors) ? "" : scapify(out.fmt,formatNames(out,data.authors))
end

"Format organization in small caps"
function formatOrganization(out::Output, data::BibInternal.Entry)::String
  scapify(out.fmt,data.in.organization)
end

"Format editor names in small caps, postfixed by 'ed(s).'"
function formatEditors(out::Output, data::BibInternal.Entry)::String
  empty(data.editors) ? "" : scapify(out.fmt,formatNames(out,data.editors)) * (length(data.editors) > 1 ? ", eds." : ", ed.")
end

"Form editor names with postfixed by 'ed(s).'"
function formatInEditors(out::Output, data::BibInternal.Entry)::String
  empty(data.editors) ? "" : formatNames(out,data.editors) * (length(data.editors) > 1 ? ", eds." : ", ed.")
end

"Emphasize the title and convert it into sentence-case."
function formatTitle(out::Output, data::BibInternal.Entry)::String
  empty(data.title) ? "" : emphasize(out.fmt, uppercasefirst(lowercase(data.title)))
end

"Emphasize the title."
function formatBTitle(out::Output, data::BibInternal.Entry)::String
  emphasize(out.fmt, data.title)
end

"Format the dat as '[mm ]yyyy'."
function formatDate(out::Output, data::BibInternal.Entry)::String
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
function formatBVolume(out::Output, data::BibInternal.Entry)::String
  if empty(data.in.volume)
    return ""
  else
    str = tieConnect(out.fmt,["vol.",data.in.volume])
    if !empty(data.in.series)
      str *= " of " * data.in.series
    end
    if !empty(data.in.number)
      @warn "Can't use both 'volume' and 'number' in $(data.id)"
    end
    return str
  end
end

"Format 'no.~number in series'."
function formatNumberSeries(out::Output, data::BibInternal.Entry)::String
  if !empty(data.in.volume)
    return "" # Can't use both volume and number
  else
    if empty(data.in.number)
      return data.in.series
    else
      str = tieConnect(out.fmt, ["no.",data.in.number])
      if empty(data.in.series)
        @warn "There's a 'number' but no 'series' in $(data.id)"
      else
        str *= " in " * data.in.series
      end
      return str
    end
  end
end

"Format edition postfixed by 'ed.'."
function formatEdition(out::Output, data::BibInternal.Entry)::String
  empty(data.in.edition) ? "" : tieConnect(out.fmt, [lowercase(data.in.edition),"ed."])
end

"Format pages as 'pp.~1--2' or 'p.~1."
function formatPages(out::Output, data::BibInternal.Entry)::String
  if empty(data.in.pages)
    return ""
  else
    return length(split(data.in.pages,r"[-,]")) > 1 ?
      tieConnect(out.fmt,["pp.",dashify(out.fmt,data.in.pages)]) :
      tieConnect(out.fmt,["p.",data.in.pages])
  end
end

"Format as 'volume (year)'."
function formatVolYear(out::Output, data::BibInternal.Entry)::String
  str = data.in.volume
  if empty(data.date.year)
    @warn "Empty 'year' in $(data.id)."
  else
    str *= " ($(data.date.year))"
  end
  str
end

"Format chaper and pages as 'ch.~chapter, pp.~1--2'."
function formatChapterPages(out::Output, data::BibInternal.Entry)::String
  if empty(data.in.chapter)
    return formatPages(out,data)
  else
    str = empty(data.fields,"type") ?
      tieConnect(out.fmt,["ch.",data.in.chapter]) :
      tieOrSpaceConnect(out.fmt,[lowercase(data.fields["type"]),data.in.chapter])

    if !empty(data.in.pages)
      str *= ", " * formatPages(out,data)
    end
    return str
  end
end

"Formate booktitle as 'in booktitle[, editors...]'."
function formatInEdBooktitle(out::Output, data::BibInternal.Entry)::String
  if empty(data.booktitle)
    return ""
  else
    return empty(data.editors) ?
      "in " * data.booktitle :
      "in " * data.booktitle * ", " * formatInEditors(out, data)
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
function formatThesisType(out::Output, data::BibInternal.Entry, tite::String)::String
  empty(data.fields,"type") ? title : lowercase(data.fields["type"])
end

"Format the tech report number as 'Tech. Rep.~number' or 'type~number'"
function formatTrNumber(out::Output, data::BibInternal.Entry)::String
  str = empty(data.fields,"type") ? "Tech. Rep." : data.fields["type"]
  empty(data.in.number) ? lowercase(str) : tieOrSpaceConnect(out.fmt,[str,data.in.number])
end

# TODO: crossref not implemented


function article(fmt::OutputFormat, data::BibInternal.Entry)
  out = Output(fmt)
  outputCheck!(out, formatAuthors(out, data), "Empty 'author' in $(data.id).")
  outputCheck!(out, formatTitle(out, data), "Empty 'title' in $(data.id).")
  outputCheck!(out, replaceJournal(data.in.journal), "Empty 'journal' in $(data.id).")
  output!(out, formatVolYear(out, data))
  output!(out, formatPages(out, data))

  newBlock!(out)
  output!(out, get(data.fields,"note",""))

  finEntry!(out)
end


function book(fmt::OutputFormat, data::BibInternal.Entry)
  out = Output(fmt)
  if empty(data.authors)
    outputCheck!(out, formatEditors(out, data), "Empty 'author' and 'editor' in $(data.id).")
  else
    outputNonNull!(out, formatAuthors(out, data))
    if !empty(data.editors)
      @warn "Can't use both 'author' and 'editor' fields in $(data.id)"
    end
  end

  outputCheck!(out, formatBTitle(out, data), "Empty 'title' in $(data.id).")
  output!(out, formatBVolume(out,data))
  output!(out, formatNumberSeries(out,data))
  outputCheck!(out, data.in.publisher, "Empty 'publisher' in $(data.id).")
  output!(out, data.in.address)
  output!(out, formatEdition(out,data))
  outputCheck!(out, formatDate(out,data), "Empty 'year' in $(data.id).")

  newBlock!(out)
  output!(out, get(data.fields,"note",""))

  finEntry!(out)
end


function booklet(fmt::OutputFormat, data::BibInternal.Entry)
  out = Output(fmt)
  output!(out, formatAuthors(out, data))
  outputCheck!(out, formatTitle(out, data), "Empty 'title' in $(data.id)")

  newBlockCheck!(out, data.access.howpublished)
  output!(out, data.access.howpublished)
  output!(out, data.in.address)
  output!(out, formatDate(out, data))

  newBlock!(out)
  output!(out, get(data.fields,"note",""))

  finEntry!(out)
end


function inbook(fmt::OutputFormat, data::BibInternal.Entry)
  out = Output(fmt)
  if empty(data.authors)
    outputCheck!(out, formatEditors(out, data), "Empty 'author' and 'editor' in $(data.id)")
  else
    outputNonNull!(out, formatAuthors(out, data))
    if !empty(data.editors)
      @warn "Can't use both 'author' and 'editor' fields in $(data.id)"
    end
  end

  outputCheck!(out, formatBTitle(out, data), "Empty 'title' in $(data.id)")
  output!(out, formatBVolume(out, data))
  output!(out, formatNumberSeries(out, data))
  outputCheck!(out, data.in.publisher, "Empty 'publisher' in $(data.id)")
  output!(out, data.in.address)
  output!(out, formatEdition(out, data))
  outputCheck!(out, formatDate(out, data), "Empty 'year' in $(data.id)")
  outputCheck!(out, formatChapterPages(out, data), "Empty 'chapter' and 'pages' in $(data.id)")

  newBlock!(out)
  output!(out, get(data.fields,"note",""))

  finEntry!(out)
end


function incollection(fmt::OutputFormat, data::BibInternal.Entry)
  out = Output(fmt)
  outputCheck!(out, formatAuthors(out, data), "Empty 'author' in $(data.id)")
  outputCheck!(out, formatTitle(out, data), "Empty 'title' in $(data.id)")
  outputCheck!(out, formatInEdBooktitle(out, data), "Empty 'booktitle' in $(data.id)")
  output!(out, formatBVolume(out, data))
  output!(out, formatNumberSeries(out, data))
  outputCheck!(out, data.in.publisher, "Empty 'publisher' in $(data.id)")
  output!(out, data.in.address)
  output!(out, formatEdition(out, data))
  outputCheck!(out, formatDate(out, data), "Empty 'year' in $(data.id)")
  output!(out, formatChapterPages(out, data))

  newBlock!(out)
  output!(out, get(data.fields,"note",""))

  finEntry!(out)
end


function inproceedings(fmt::OutputFormat, data::BibInternal.Entry)
  out = Output(fmt)
  outputCheck!(out, formatAuthors(out, data), "Empty 'author' in $(data.id)")
  outputCheck!(out, formatTitle(out, data), "Empty 'title' in $(data.id)")
  outputCheck!(out, formatInEdBooktitle(out, data), "Empty 'booktitle' in $(data.id)")
  output!(out, formatBVolume(out, data))
  output!(out, formatNumberSeries(out, data))

  if empty(data.in.address)
    output!(out, data.in.organization)
    output!(out, data.in.publisher)
    outputCheck!(out, formatDate(out, data), "Empty 'year' in $(data.id)")
  else
    outputNonNull!(out, data.in.address)
    outputCheck!(out, formatDate(out, data), "Empty 'year' in $(data.id)")
    output!(out, data.in.organization)
    output!(out, data.in.publisher)
  end

  output!(out, formatPages(out, data))

  newBlock!(out)
  output!(out, get(data.fields,"note",""))

  finEntry!(out)
end


conference(fmt::OutputFormat, data::BibInternal.Entry) = inproceedings(fmt, data)


function manual(fmt::OutputFormat, data::BibInternal.Entry)
  out = Output(fmt)
  if empty(data.authors)
    output!(out, formatOrganization(out, data))
  else
    outputNonNull!(out, formatAuthors(out, data))
  end
  outputCheck!(out, formatBTitle(out, data), "Empty 'title' in $(data.id)")
  if !empty(data.authors)
    output!(out, data.in.organization)
  end
  output!(out, data.in.address)
  output!(out, formatEdition(out, data))
  output!(out, formatDate(out, data))

  newBlock!(out)
  output!(out, get(data.fields,"note",""))

  finEntry!(out)
end


function mastersthesis(fmt::OutputFormat, data::BibInternal.Entry)
  out = Output(fmt)
  outputCheck!(out, formatAuthors(out, data), "Empty 'author' in $(data.id)")
  outputCheck!(out, formatTitle(out, data), "Empty 'title' in $(data.id)")
  outputNonNull!(out, formatThesisType(out, data, "Master's thesis"))
  outputCheck!(out, data.in.school, "Empty 'school' in $(data.id)")
  output!(out, data.in.address)
  outputCheck!(out, formatDate(out, data), "Empty 'year' in $(data.id)")

  newBlock!(out)
  output!(out, get(data.fields,"note",""))

  finEntry!(out)
end


function misc(fmt::OutputFormat, data::BibInternal.Entry)
  out = Output(fmt)
  output!(out, formatAuthors(out, data))
  output!(out, formatTitle(out, data))

  newBlockCheck!(out, data.access.howpublished)
  output!(out, data.access.howpublished)
  output!(out, formatDate(out, data))

  newBlock!(out)
  output!(out, get(data.fields,"note",""))
  emptyMiscCheck(data)

  finEntry!(out)
end


function phdthesis(fmt::OutputFormat, data::BibInternal.Entry)
  out = Output(fmt)
  outputCheck!(out, formatAuthors(out, data), "Empty 'author' in $(data.id)")
  outputCheck!(out, formatBTitle(out, data), "Empty 'title' in $(data.id)")
  outputNonNull!(out, formatThesisType(out, data, "PhD thesis"))
  outputCheck!(out, data.in.school, "Empty 'school' in $(data.id)")
  output!(out, data.in.address)
  outputCheck!(out, formatDate(out, data), "Empty 'year' in $(data.id)")

  newBlock!(out)
  output!(out, get(data.fields,"note",""))

  finEntry!(out)
end


function proceedings(fmt::OutputFormat, data::BibInternal.Entry)
  out = Output(fmt)
  if empty(data.editors)
    output!(out, formatOrganization(out, data))
  else
    outputNonNull!(out, formatEditors(out, data))
  end
  outputCheck!(out, formatBTitle(out, data), "Empty 'title' in $(data.id)")
  output!(out, formatBVolume(out, data))
  output!(out, formatNumberSeries(out, data))
  if empty(data.in.address)
    if !empty(data.editors)
      output!(out, data.in.organization)
    end
    output!(out, data.in.publisher)
    outputCheck!(out, formatDate(out, data), "Empty 'year' in $(data.id)")
  else
    outputNonNull!(out, data.in.address)
    outputCheck!(out, formatDate(out, data), "Empty 'year' in $(data.id)")
    if !empty(data.editors)
      output!(out, data.in.organization)
    end
    output!(out, data.in.publisher)
  end

  newBlock!(out)
  output!(out, get(data.fields,"note",""))

  finEntry!(out)
end


function techreport(fmt::OutputFormat, data::BibInternal.Entry)
  out = Output(fmt)
  outputCheck!(out, formatAuthors(out, data), "Empty 'author' in $(data.id)")
  outputCheck!(out, formatTitle(out, data), "Empty 'title' in $(data.id)")
  outputNonNull!(out, formatTrNumber(out, data))
  outputCheck!(out, data.in.institution, "Empty 'institution' in $(data.id)")
  output!(out, data.in.address)
  outputCheck!(out, formatDate(out, data), "Empty 'year' in $(data.id)")

  newBlock!(out)
  output!(out, get(data.fields,"note",""))

  finEntry!(out)
end


function unpublished(fmt::OutputFormat, data::BibInternal.Entry)
  out = Output(fmt)
  outputCheck!(out, formatAuthors(out, data), "Empty 'author' in $(data.id)")
  outputCheck!(out, formatTitle(out, data), "Empty 'title' in $(data.id)")

  newBlock!(out)
  outputCheck!(out, get(data.fields,"note",""), "Empty 'not' in $(data.id)")
  output!(out, formatDate(out, data))

  finEntry!(out)
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