struct Abbrv <: BibliographyStyle end

module BibliographyStyleAbbrv

using ...BibFormatter: OutputFormat, outputAddPeriod
using ..BibliographyStyleCommon: empty, emphasize, scapify, dashify, tieConnect, tieOrSpaceConnect, replaceMonth, formatNamesFLast
import BibInternal

@enum OutputState begin
  BEFORE_ALL
  MID_SENTENCE
  AFTER_SENTENCE
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
      out.sentence = str
    else
      if out.state == BEFORE_ALL
        out.sentence = str
      else
        addPeriod!(out)
        out.sentence *= " " * str
      end
    end
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
newBlockCheck!(out::Output, str1::AbstractString, str2::AbstractString) = !(empty(str1) && empty(str2)) && newBlock!(out)

function newSentence!(out::Output)
  if out.state != AFTER_BLOCK && out.state != BEFORE_ALL
    out.state = AFTER_SENTENCE
  end
end

newSentenceCheck!(out::Output, str::AbstractString) = !empty(str) && newSentence!(out)
newSentenceCheck!(out::Output, str1::AbstractString, str2::AbstractString) = !(empty(str1) && empty(str2)) && newSentence!(out)



const journalAbbrv = Dict(
  "acmcs" => "ACM Comput. Surv.",
  "acta" => "Acta Inf.",
  "cacm" => "Commun. ACM",
  "ibmjrd" => "IBM J. Res. Dev.",
  "ibmsj" => "IBM Syst.~J.",
  "ieeese" => "IEEE Trans. Softw. Eng.",
  "ieeetc" => "IEEE Trans. Comput.",
  "ieeetcad" => "IEEE Trans. Comput.-Aided Design Integrated Circuits",
  "ipl" => "Inf. Process. Lett.",
  "jacm" => "J.~ACM",
  "jcss" => "J.~Comput. Syst. Sci.",
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

"Format author names"
function formatAuthors(out::Output, data::BibInternal.Entry)::String
  empty(data.authors) ? "" : formatNames(out,data.authors)
end

"Form editor names with postfixed by 'editor(s).'"
function formatEditors(out::Output, data::BibInternal.Entry)::String
  empty(data.editors) ? "" :
    formatNames(out,data.editors) * (length(data.editors) > 1 ? ", editors" : ", editor")
end

"Convert the title into sentence-case."
function formatTitle(out::Output, data::BibInternal.Entry)::String
  empty(data.title) ? "" : uppercasefirst(lowercase(data.title))
end

"Emphasize the title."
function formatBTitle(out::Output, data::BibInternal.Entry)::String
  emphasize(out.fmt, data.title)
end

"Format the date as '[mm ]yyyy'."
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

"Format 'volume~V of series'."
function formatBVolume(out::Output, data::BibInternal.Entry)::String
  if empty(data.in.volume)
    return ""
  else
    str = tieOrSpaceConnect(out.fmt,["volume",data.in.volume])
    if !empty(data.in.series)
      str *= " of " * emphasize(out.fmt, data.in.series)
    end
    if !empty(data.in.number)
      @warn "Can't use both 'volume' and 'number' in $(data.id)"
    end
    return str
  end
end

"Format 'number~N in series'."
function formatNumberSeries(out::Output, data::BibInternal.Entry)::String
  if !empty(data.in.volume)
    return "" # Can't use both volume and number
  else
    if empty(data.in.number)
      return data.in.series
    else
      str = tieOrSpaceConnect(out.fmt,
        [(out.state == MID_SENTENCE ? "number" : "Number"),data.in.number])
      if empty(data.in.series)
        @warn "There's a 'number' but no 'series' in $(data.id)"
      else
        str *= " in " * data.in.series
      end
      return str
    end
  end
end

"Format edition postfixed by 'edition'."
function formatEdition(out::Output, data::BibInternal.Entry)::String
  empty(data.in.edition) ? "" :
    (out.state == MID_SENTENCE ?
      lowercase(data.in.edition) :
      uppercasefirst(lowercase(data.in.edition))) * " edition"
end

"Format pages as 'pages~1--2' or 'page~1."
function formatPages(out::Output, data::BibInternal.Entry)::String
  if empty(data.in.pages)
    return ""
  else
    return length(split(data.in.pages,r"[-,]")) > 1 ?
      tieOrSpaceConnect(out.fmt,["pages",dashify(out.fmt,data.in.pages)]) :
      tieOrSpaceConnect(out.fmt,["page",data.in.pages])
  end
end

"Format volume, number and pages as V(N):P"
function formatVolNumPages(out::Output, data::BibInternal.Entry)::String
  str = data.in.volume
  if !empty(data.in.number)
    str *= "($(data.in.number))"
    if empty(data.in.volume)
      @warn "There's a 'number' but no 'volume' in $(data.id)"
    end
  end
  if !empty(data.in.pages)
    if empty(str)
      str *= formatPages(out, data)
    else
      str *= ":" * dashify(out.fmt,data.in.pages)
    end
  end
  str
end

"Format chaper and pages as 'chapter~C, pages~1--2'."
function formatChapterPages(out::Output, data::BibInternal.Entry)::String
  if empty(data.in.chapter)
    return formatPages(out,data)
  else
    str = empty(data.fields,"type") ?
      tieOrSpaceConnect(out.fmt,["chapter",data.in.chapter]) :
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
      "In " * emphasize(data.booktitle) :
      "In " * formatEditors(out, data) * ", " * emphasize(out.fmt,data.booktitle)
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

"Transform the thesis type into sentencecase if set."
function formatThesisType(out::Output, data::BibInternal.Entry, tite::String)::String
  empty(data.fields,"type") ? title : uppercasefirst(lowercase(data.fields["type"]))
end

"Format the tech report number as 'Technical Report~number' or 'Type~number'"
function formatTrNumber(out::Output, data::BibInternal.Entry)::String
  str = empty(data.fields,"type") ? "Technical Report" : data.fields["type"]
  empty(data.in.number) ? uppercasefirst(lowercase(str)) : tieOrSpaceConnect(out.fmt,[str,data.in.number])
end


# TODO: crossref not implemented

function article(fmt::OutputFormat, data::BibInternal.Entry)
  out = Output(fmt)
  outputCheck!(out, formatAuthors(out, data), "Empty 'author' in $(data.id).")

  newBlock!(out)
  outputCheck!(out, formatTitle(out, data), "Empty 'title' in $(data.id).")

  newBlock!(out)
  outputCheck!(out, emphasize(fmt,replaceJournal(data.in.journal)), "Empty 'journal' in $(data.id).")
  output!(out, formatVolNumPages(out, data))
  outputCheck!(out, formatDate(out, data), "Empty 'year' in $(data.id).")

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

  newBlock!(out)
  outputCheck!(out, formatBTitle(out, data), "Empty 'title' in $(data.id).")
  output!(out, formatBVolume(out,data))

  newBlock!(out)
  output!(out, formatNumberSeries(out,data))

  newSentence!(out)
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

  newBlock!(out)
  outputCheck!(out, formatTitle(out, data), "Empty 'title' in $(data.id)")

  newBlockCheck!(out, data.access.howpublished, data.in.address)
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
    output!(out, formatAuthors(out, data))
    if !empty(data.editors)
      @warn "Can't use both 'author' and 'editor' fields in $(data.id)"
    end
  end

  newBlock!(out)
  outputCheck!(out, formatBTitle(out, data), "Empty 'title' in $(data.id)")
  output!(out, formatBVolume(out, data))
  outputCheck!(out, formatChapterPages(out, data), "Empty 'chapter' and 'pages' in $(data.id)")

  newBlock!(out)
  output!(out, formatNumberSeries(out, data))

  newSentence!(out)
  outputCheck!(out, data.in.publisher, "Empty 'publisher' in $(data.id)")
  output!(out, data.in.address)
  output!(out, formatEdition(out, data))
  outputCheck!(out, formatDate(out, data), "Empty 'year' in $(data.id)")

  newBlock!(out)
  output!(out, get(data.fields,"note",""))

  finEntry!(out)
end


function incollection(fmt::OutputFormat, data::BibInternal.Entry)
  out = Output(fmt)
  outputCheck!(out, formatAuthors(out, data), "Empty 'author' in $(data.id)")

  newBlock!(out)
  outputCheck!(out, formatTitle(out, data), "Empty 'title' in $(data.id)")

  newBlock!(out)
  outputCheck!(out, formatInEdBooktitle(out, data), "Empty 'booktitle' in $(data.id)")
  output!(out, formatBVolume(out, data))
  output!(out, formatNumberSeries(out, data))
  output!(out, formatChapterPages(out, data))

  newSentence!(out)
  outputCheck!(out, data.in.publisher, "Empty 'publisher' in $(data.id)")
  output!(out, data.in.address)
  output!(out, formatEdition(out, data))
  outputCheck!(out, formatDate(out, data), "Empty 'year' in $(data.id)")

  newBlock!(out)
  output!(out, get(data.fields,"note",""))

  finEntry!(out)
end


function inproceedings(fmt::OutputFormat, data::BibInternal.Entry)
  out = Output(fmt)
  outputCheck!(out, formatAuthors(out, data), "Empty 'author' in $(data.id)")

  newBlock!(out)
  outputCheck!(out, formatTitle(out, data), "Empty 'title' in $(data.id)")

  newBlock!(out)
  outputCheck!(out, formatInEdBooktitle(out, data), "Empty 'booktitle' in $(data.id)")
  output!(out, formatBVolume(out, data))
  output!(out, formatNumberSeries(out, data))
  output!(out, formatPages(out, data))

  if empty(data.in.address)
    newSentenceCheck!(out, data.in.organization, data.in.publisher)
    output!(out, data.in.organization)
    output!(out, data.in.publisher)
    outputCheck!(out, formatDate(out, data), "Empty 'year' in $(data.id)")
  else
    outputNonNull!(out, data.in.address)
    outputCheck!(out, formatDate(out, data), "Empty 'year' in $(data.id)")
    newSentence!(out)
    output!(out, data.in.organization)
    output!(out, data.in.publisher)
  end

  newBlock!(out)
  output!(out, get(data.fields,"note",""))

  finEntry!(out)
end


conference(fmt::OutputFormat, data::BibInternal.Entry) = inproceedings(fmt, data)


function manual(fmt::OutputFormat, data::BibInternal.Entry)
  out = Output(fmt)
  if empty(data.authors)
    if !empty(data.in.organization)
      outputNonNull!(out, data.in.organization)
      output!(out, data.in.address)
    end
  else
    outputNonNull!(out, formatAuthors(out, data))
  end

  newBlock!(out)
  outputCheck!(out, formatBTitle(out, data), "Empty 'title' in $(data.id)")
  if empty(data.authors)
    if empty(Data.in.organization)
      newBlockCheck!(out, data.in.address)
      output!(out, data.in.address)
    end
  else
    newBlockCheck!(out, data.in.organization, data.in.address)
    output!(out, data.in.organization)
    output!(out, data.in.address)
  end
  output!(out, formatEdition(out, data))
  output!(out, formatDate(out, data))

  newBlock!(out)
  output!(out, get(data.fields,"note",""))

  finEntry!(out)
end


function mastersthesis(fmt::OutputFormat, data::BibInternal.Entry)
  out = Output(fmt)
  outputCheck!(out, formatAuthors(out, data), "Empty 'author' in $(data.id)")

  newBlock!(out)
  outputCheck!(out, formatTitle(out, data), "Empty 'title' in $(data.id)")

  newBlock!(out)
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

  newBlockCheck!(out, data.title, data.access.howpublished)
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

  newBlock!(out)
  outputCheck!(out, formatBTitle(out, data), "Empty 'title' in $(data.id)")

  newBlock!(out)
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
    output!(out, data.in.organization)
  else
    outputNonNull!(out, formatEditors(out, data))
  end

  newBlock!(out)
  outputCheck!(out, formatBTitle(out, data), "Empty 'title' in $(data.id)")
  output!(out, formatBVolume(out, data))
  output!(out, formatNumberSeries(out, data))

  if empty(data.in.address)
    if empty(data.editors)
      newSentenceCheck!(out, data.in.publisher)
    else
      newSentenceCheck!(out, data.in.organization, data.in.publisher)
      output!(out, data.in.organization)
    end
    output!(out, data.in.publisher)
    outputCheck!(out, formatDate(out, data), "Empty 'year' in $(data.id)")
  else
    outputNonNull!(out, data.in.address)
    outputCheck!(out, formatDate(out, data), "Empty 'year' in $(data.id)")

    newSentence!(out)
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

  newBlock!(out)
  outputCheck!(out, formatTitle(out, data), "Empty 'title' in $(data.id)")

  newBlock!(out)
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

  newBlock!(out)
  outputCheck!(out, formatTitle(out, data), "Empty 'title' in $(data.id)")

  newBlock!(out)
  outputCheck!(out, get(data.fields,"note",""), "Empty 'not' in $(data.id)")
  output!(out, formatDate(out, data))

  finEntry!(out)
end


end # module BibliographyStyleAbbrv


# F. M. Last1, F. M. Last2, and F. M. Last3.
# Title.
# Journal, 123(234):1-2, mm yyyy.
# This is a note.
function formatArticle(fmt::OutputFormat, style::Abbrv, data::BibInternal.Entry)
  BibliographyStyleAbbrv.article(fmt, data)
end

# F. M. Last1, F. M. Last2, and F. M. Last3.
# Title, volume v123 of Series.
# Publisher, Address, edition edition, mm yyyy.
# This is a note.
function formatBook(fmt::OutputFormat, style::Abbrv, data::BibInternal.Entry)
  BibliographyStyleAbbrv.book(fmt, data)
end

# F. M. Last1, F. M. Last2, and F. M. Last3.
# Title, chapter Chapter, pages 1-2.
# Number n234 in Series.
# Publisher, Address, edition edition, mm yyyy.
# This is a note.
function formatBooklet(fmt::OutputFormat, style::Abbrv, data::BibInternal.Entry)
  BibliographyStyleAbbrv.booklet(fmt, data)
end

# F. M. Last1, F. M. Last2, and F. M. Last3.
# Title, volume v123 of Series, chapter Chapter, pages 1-2.
# Publisher, Address, edition edition, mm yyyy.
# This is a note.
function formatInBook(fmt::OutputFormat, style::Abbrv, data::BibInternal.Entry)
  BibliographyStyleAbbrv.inbook(fmt, data)
end

# F. M. Last1, F. M. Last2, and F. M. Last3.
# Title.
# In E. ELast1, E. ELast2, and E. ELast3, editors, Booktitle, volume v123 of Series, chapter Chapter, pages 1-2.
# Publisher, Address, edition edition, mm yyyy.
# This is a note.
function formatInCollection(fmt::OutputFormat, style::Abbrv, data::BibInternal.Entry)
  BibliographyStyleAbbrv.incollection(fmt, data)
end

# F. M. Last1, F. M. Last2, and F. M. Last3.
# Title.
# Organization, Address, edition edition, mm yyyy.
# This is a note.
function formatManual(fmt::OutputFormat, style::Abbrv, data::BibInternal.Entry)
  BibliographyStyleAbbrv.manual(fmt, data)
end

# F. M. Last.
# Title.
# Type, School, Address, mm yyyy.
# This is a note.
function formatMastersThesis(fmt::OutputFormat, style::Abbrv, data::BibInternal.Entry)
  BibliographyStyleAbbrv.mastersthesis(fmt, data)
end

# F. M. Last1, F. M. Last2, and F. M. Last3.
# Title.
# How it is published, mm yyyy.
# This is a note.
function formatMisc(fmt::OutputFormat, style::Abbrv, data::BibInternal.Entry)
  BibliographyStyleAbbrv.misc(fmt, data)
end

# F. M. Last.
# Title.
# Type, School, Address, mm yyyy.
# This is a note.
function formatPhDThesis(fmt::OutputFormat, style::Abbrv, data::BibInternal.Entry)
  BibliographyStyleAbbrv.phdthesis(fmt, data)
end

# E. E. ELast1, E. E. ELast2, and E. E. ELast3, editors.
# Title, volume v123 of Series, Address, mm yyyy.
# Organization, Publisher.
# This is a note.
function formatProceedings(fmt::OutputFormat, style::Abbrv, data::BibInternal.Entry)
  BibliographyStyleAbbrv.proceedings(fmt, data)
end

# F. M. Last1, F. M. Last2, and F. M. Last3.
# Title.
# Type n234, Institution, Address, mm yyyy.
# This is a note.
function formatTechreport(fmt::OutputFormat, style::Abbrv, data::BibInternal.Entry)
  BibliographyStyleAbbrv.techreport(fmt, data)
end

# F. M. Last1, F. M. Last2, and F. M. Last3.
# Title.
# This is a note, mm yyyy.
function formatUnpublished(fmt::OutputFormat, style::Abbrv, data::BibInternal.Entry)
  BibliographyStyleAbbrv.unpublished(fmt, data)
end