struct Acm <: BibliographyStyle end

module BibliographyStyleAcm

using ...BibFormatter: OutputFormat, dashify, empty, emptyMiscCheck, emphasize, emphasizeic, formatNameFLast, formatNameLastF, outputAddPeriod, replaceMonth, scapify, tieConnect, tieOrSpaceConnect
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


"""
    formatNames(out, names)

Format names in ACM bibliography style for top-level author/editor lists.
Each name is rendered in "von Last, Jr, F." order (`formatNameLastF`), with
ACM separators: `A, B, and C` (or `, et~al.` for `others`).

Use this for primary name lists such as `formatAuthors`/`formatEditors`.
For names inside an `In ...` phrase, use [`formatInNames`](@ref), which uses a
different per-name order and final separator behavior.
"""
function formatNames(out::Output, names::BibInternal.Names)::String
  s = ""
  numnames = length(names)
  for (i, n) in enumerate(names)
    t = formatNameLastF(out.fmt, n.particle, n.last, n.junior, n.first, n.middle) # {vv~}{ll}{, jj}{, f.}
    if i > 1
      if numnames - i > 0
        s *= ", " * t
      else
        s *= (t == "others" ? ", et~al." : ", and " * t)
      end
    else
      s = t
    end
  end
  s
end

"""
    formatInNames(out, names)

Format names for nested "In ..." contexts (for example editors in incollection
or inproceedings entries). Unlike [`formatNames`](@ref), each name is rendered
as "F. von Last, Jr" (`formatNameFLast`), and for lists longer than two names
it inserts an Oxford comma before the final "and".
"""
function formatInNames(out::Output, names::BibInternal.Names)::String
  s = ""
  numnames = length(names)
  for (i, n) in enumerate(names)
    t = formatNameFLast(out.fmt, n.particle, n.last, n.junior, n.first, n.middle) # {f.~}{vv~}{ll}{, jj}
    if i > 1
      if numnames - i > 0
        s *= ", " * t
      else
        if numnames > 2
          s *= ","
        end
        s *= (t == "others" ? " et~al." : " and " * t)
      end
    else
      s = t
    end
  end
  s
end

"""Format author names in small caps."""
formatAuthors(out::Output, data::BibInternal.Entry)::String = empty(data.authors) ? "" : scapify(out.fmt, formatNames(out, data.authors))

"""Format editor names in small caps postfixed by 'Ed.' or 'Eds.'."""
function formatEditors(out::Output, data::BibInternal.Entry)::String
  empty(data.editors) ? "" : scapify(out.fmt, formatNames(out, data.editors)) * (length(data.editors) > 1 ? ", Eds." : ", Ed.")
end

"""Format in-entry editor names postfixed by 'Ed.' or 'Eds.'."""
function formatInEditors(out::Output, data::BibInternal.Entry)::String
  empty(data.editors) ? "" : formatInNames(out, data.editors) * (length(data.editors) > 1 ? ", Eds." : ", Ed.")
end

"""Convert title to sentence-case."""
formatTitle(out::Output, data::BibInternal.Entry)::String = empty(data.title) ? "" : uppercasefirst(lowercase(data.title))
"""Emphasize book-like titles."""
formatBTitle(out::Output, data::BibInternal.Entry)::String = emphasize(out.fmt, data.title)

"""Format date as '[mm ]yyyy' with warning on month-only data."""
function formatDate(out::Output, data::BibInternal.Entry)::String
  if empty(data.date.year)
    if empty(data.date.month)
      ""
    else
      @warn "There's a 'month' but not 'year' in $(data.id)"
      replaceMonth(data.date.month)
    end
  else
    empty(data.date.month) ? data.date.year : replaceMonth(data.date.month) * " " * data.date.year
  end
end

"""Format volume as 'vol.~V'."""
formatVolume(out::Output, volume::AbstractString)::String = tieConnect(out.fmt, ["vol.", volume])
"""Format number as 'no.~N'."""
formatNumber(out::Output, number::AbstractString)::String = tieConnect(out.fmt, ["no.", number])

"""Format 'vol.~V of series'."""
function formatBVolume(out::Output, data::BibInternal.Entry)::String
  if empty(data.in.volume)
    ""
  else
    s = formatVolume(out, data.in.volume)
    if !empty(data.in.series)
      s *= " of " * emphasize(out.fmt, data.in.series)
    end
    if !empty(data.in.number)
      @warn "Can't use both 'volume' and 'number' in $(data.id)"
    end
    s
  end
end

"""Format 'no.~N in series' with sentence-aware capitalization."""
function formatNumberSeries(out::Output, data::BibInternal.Entry)::String
  if !empty(data.in.volume)
    ""
  elseif empty(data.in.number)
    data.in.series
  else
    pfx = out.state == MID_SENTENCE ? "no." : "No."
    s = tieConnect(out.fmt, [pfx, data.in.number])
    if empty(data.in.series)
      @warn "There's a 'number' but no 'series' in $(data.id)"
    else
      s *= " in " * data.in.series
    end
    s
  end
end

"""Format edition postfixed by 'ed.' with sentence-aware capitalization."""
function formatEdition(out::Output, data::BibInternal.Entry)::String
  if empty(data.in.edition)
    ""
  else
    p = out.state == MID_SENTENCE ? lowercase(data.in.edition) : uppercasefirst(lowercase(data.in.edition))
    tieConnect(out.fmt, [p, "ed."])
  end
end

"""Format page range using output-specific dash styling."""
formatPages(out::Output, data::BibInternal.Entry)::String = empty(data.in.pages) ? "" : dashify(out.fmt, data.in.pages)

"""Format pages as 'p.~P' or 'pp.~P1--P2'."""
function formatPPPages(out::Output, data::BibInternal.Entry)::String
  if empty(data.in.pages)
    ""
  else
    p = length(split(data.in.pages, r"[-,+]")) > 1 ? "pp." : "p."
    tieConnect(out.fmt, [p, dashify(out.fmt, data.in.pages)])
  end
end

"""Format journal/volume/number/date as a single ACM journal phrase."""
function formatJournalVolNumDate(out::Output, data::BibInternal.Entry)::String
  if empty(data.in.journal)
    @warn "Empty 'journal' in $(data.id)"
    return ""
  end

  s = data.in.journal
  if !empty(data.in.volume)
    s *= " " * data.in.volume
  end

  if empty(data.in.number)
    s = emphasizeic(out.fmt, s)
  else
    s = emphasize(out.fmt, s) * ", " * data.in.number
  end

  if empty(data.date.year)
    @warn "Empty 'year' in $(data.id)"
  end
  s * " (" * formatDate(out, data) * ")"
end

"""Format chapter and pages as 'ch.~C, pp.~P'."""
function formatChapterPages(out::Output, data::BibInternal.Entry)::String
  if empty(data.in.chapter)
    formatPPPages(out, data)
  else
    pfx = empty(data.fields, "type") ? "ch." : lowercase(data.fields["type"])
    s = tieOrSpaceConnect(out.fmt, [pfx, data.in.chapter])
    if !empty(data.in.pages)
      s *= ", " * formatPPPages(out, data)
    end
    s
  end
end

"""Format booktitle and optional editors as an 'In ...' phrase."""
function formatInEdBooktitle(out::Output, data::BibInternal.Entry)::String
  if empty(data.booktitle)
    ""
  else
    s = "In " * emphasize(out.fmt, data.booktitle)
    if !empty(data.editors)
      s *= ", " * formatInEditors(out, data)
    end
    s
  end
end

"""Format proceedings title with parenthesized location/date suffix."""
function formatProcDate(out::Output, title::AbstractString, data::BibInternal.Entry)::String
  if empty(title)
    ""
  else
    if empty(data.date.year)
      @warn "Empty 'year' in $(data.id)"
      empty(data.in.address) ? emphasize(out.fmt, title) : emphasizeic(out.fmt, title) * " (" * data.in.address * ")"
    else
      date = formatDate(out, data)
      emphasizeic(out.fmt, title) * " (" * (empty(data.in.address) ? "" : data.in.address * ", ") * date * ")"
    end
  end
end

"""Format proceedings booktitle as an 'In ...' phrase with location/date."""
function formatInProcDate(out::Output, data::BibInternal.Entry)::String
  empty(data.booktitle) ? "" : "In " * formatProcDate(out, data.booktitle, data)
end

"""Use explicit thesis/report type when present, otherwise fallback text."""
function formatThesisType(data::BibInternal.Entry, default::String)::String
  empty(data.fields, "type") ? default : uppercasefirst(lowercase(data.fields["type"]))
end

"""Format technical report type and number."""
function formatTrNumber(out::Output, data::BibInternal.Entry)::String
  s = empty(data.fields, "type") ? "Tech. Rep." : data.fields["type"]
  empty(data.in.number) ? uppercasefirst(lowercase(s)) : tieOrSpaceConnect(out.fmt, [s, data.in.number])
end

# TODO: crossref not implemented

function article(fmt::OutputFormat, data::BibInternal.Entry)
  out = Output(fmt)
  outputCheck!(out, formatAuthors(out, data), "Empty 'author' in $(data.id).")

  newBlock!(out)
  outputCheck!(out, formatTitle(out, data), "Empty 'title' in $(data.id).")

  newBlock!(out)
  outputCheck!(out, formatJournalVolNumDate(out, data), "Empty 'journal' in $(data.id).")
  output!(out, formatPages(out, data))

  newBlock!(out)
  output!(out, data.note)

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
  output!(out, formatEdition(out, data))
  output!(out, formatBVolume(out, data))

  newBlock!(out)
  output!(out, formatNumberSeries(out, data))
  newSentence!(out)
  outputCheck!(out, data.in.publisher, "Empty 'publisher' in $(data.id).")
  output!(out, data.in.address)
  outputCheck!(out, formatDate(out, data), "Empty 'year' in $(data.id).")

  newBlock!(out)
  output!(out, data.note)

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
  output!(out, data.note)

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

  newBlock!(out)
  outputCheck!(out, formatBTitle(out, data), "Empty 'title' in $(data.id)")
  output!(out, formatEdition(out, data))
  output!(out, formatBVolume(out, data))

  newBlock!(out)
  output!(out, formatNumberSeries(out, data))
  newSentence!(out)
  outputCheck!(out, data.in.publisher, "Empty 'publisher' in $(data.id)")
  output!(out, data.in.address)
  outputCheck!(out, formatDate(out, data), "Empty 'year' in $(data.id)")
  outputCheck!(out, formatChapterPages(out, data), "Empty 'chapter' and 'pages' in $(data.id)")

  newBlock!(out)
  output!(out, data.note)

  finEntry!(out)
end

function incollection(fmt::OutputFormat, data::BibInternal.Entry)
  out = Output(fmt)
  outputCheck!(out, formatAuthors(out, data), "Empty 'author' in $(data.id)")

  newBlock!(out)
  outputCheck!(out, formatTitle(out, data), "Empty 'title' in $(data.id)")

  newBlock!(out)
  outputCheck!(out, formatInEdBooktitle(out, data), "Empty 'booktitle' in $(data.id)")
  output!(out, formatEdition(out, data))
  output!(out, formatBVolume(out, data))
  output!(out, formatNumberSeries(out, data))

  newSentence!(out)
  outputCheck!(out, data.in.publisher, "Empty 'publisher' in $(data.id)")
  output!(out, data.in.address)
  outputCheck!(out, formatDate(out, data), "Empty 'year' in $(data.id)")
  output!(out, formatChapterPages(out, data))

  newBlock!(out)
  output!(out, data.note)

  finEntry!(out)
end

function inproceedings(fmt::OutputFormat, data::BibInternal.Entry)
  out = Output(fmt)
  outputCheck!(out, formatAuthors(out, data), "Empty 'author' in $(data.id)")

  newBlock!(out)
  outputCheck!(out, formatTitle(out, data), "Empty 'title' in $(data.id)")

  newBlock!(out)
  outputCheck!(out, formatInProcDate(out, data), "Empty 'booktitle' in $(data.id)")
  output!(out, formatInEditors(out, data))
  output!(out, formatBVolume(out, data))
  output!(out, formatNumberSeries(out, data))
  output!(out, data.in.organization)
  output!(out, data.in.publisher)
  output!(out, formatPPPages(out, data))

  newBlock!(out)
  output!(out, data.note)

  finEntry!(out)
end

conference(fmt::OutputFormat, data::BibInternal.Entry) = inproceedings(fmt, data)

function manual(fmt::OutputFormat, data::BibInternal.Entry)
  out = Output(fmt)
  if empty(data.authors)
    output!(out, scapify(out.fmt, data.in.organization))
  else
    outputNonNull!(out, formatAuthors(out, data))
  end

  newBlock!(out)
  outputCheck!(out, formatBTitle(out, data), "Empty 'title' in $(data.id)")
  output!(out, formatEdition(out, data))
  newBlockCheck!(out, data.in.organization, data.in.address)
  output!(out, data.in.organization)
  output!(out, data.in.address)
  output!(out, formatDate(out, data))

  newBlock!(out)
  output!(out, data.note)

  finEntry!(out)
end

function mastersthesis(fmt::OutputFormat, data::BibInternal.Entry)
  out = Output(fmt)
  outputCheck!(out, formatAuthors(out, data), "Empty 'author' in $(data.id)")

  newBlock!(out)
  outputCheck!(out, formatTitle(out, data), "Empty 'title' in $(data.id)")

  newBlock!(out)
  outputNonNull!(out, formatThesisType(data, "Master's thesis"))
  outputCheck!(out, data.in.school, "Empty 'school' in $(data.id)")
  output!(out, data.in.address)
  outputCheck!(out, formatDate(out, data), "Empty 'year' in $(data.id)")

  newBlock!(out)
  output!(out, data.note)

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
  output!(out, data.note)
  emptyMiscCheck(data)

  finEntry!(out)
end

function phdthesis(fmt::OutputFormat, data::BibInternal.Entry)
  out = Output(fmt)
  outputCheck!(out, formatAuthors(out, data), "Empty 'author' in $(data.id)")

  newBlock!(out)
  outputCheck!(out, formatBTitle(out, data), "Empty 'title' in $(data.id)")

  newBlock!(out)
  outputNonNull!(out, formatThesisType(data, "PhD thesis"))
  outputCheck!(out, data.in.school, "Empty 'school' in $(data.id)")
  output!(out, data.in.address)
  outputCheck!(out, formatDate(out, data), "Empty 'year' in $(data.id)")

  newBlock!(out)
  output!(out, data.note)

  finEntry!(out)
end

function proceedings(fmt::OutputFormat, data::BibInternal.Entry)
  out = Output(fmt)
  output!(out, formatEditors(out, data))

  newBlock!(out)
  outputCheck!(out, formatProcDate(out, data.title, data), "Empty 'title' in $(data.id)")
  output!(out, formatBVolume(out, data))
  output!(out, formatNumberSeries(out, data))
  output!(out, data.in.organization)
  output!(out, data.in.publisher)

  newBlock!(out)
  output!(out, data.note)

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
  output!(out, data.note)

  finEntry!(out)
end

function unpublished(fmt::OutputFormat, data::BibInternal.Entry)
  out = Output(fmt)
  outputCheck!(out, formatAuthors(out, data), "Empty 'author' in $(data.id)")

  newBlock!(out)
  outputCheck!(out, formatTitle(out, data), "Empty 'title' in $(data.id)")

  newBlock!(out)
  outputCheck!(out, data.note, "Empty 'note' in $(data.id)")
  output!(out, formatDate(out, data))

  finEntry!(out)
end

end # module BibliographyStyleAcm


function formatArticle(fmt::OutputFormat, style::Acm, data::BibInternal.Entry)
  BibliographyStyleAcm.article(fmt, data)
end

function formatBook(fmt::OutputFormat, style::Acm, data::BibInternal.Entry)
  BibliographyStyleAcm.book(fmt, data)
end

function formatBooklet(fmt::OutputFormat, style::Acm, data::BibInternal.Entry)
  BibliographyStyleAcm.booklet(fmt, data)
end

function formatInBook(fmt::OutputFormat, style::Acm, data::BibInternal.Entry)
  BibliographyStyleAcm.inbook(fmt, data)
end

function formatInCollection(fmt::OutputFormat, style::Acm, data::BibInternal.Entry)
  BibliographyStyleAcm.incollection(fmt, data)
end

function formatManual(fmt::OutputFormat, style::Acm, data::BibInternal.Entry)
  BibliographyStyleAcm.manual(fmt, data)
end

function formatMastersThesis(fmt::OutputFormat, style::Acm, data::BibInternal.Entry)
  BibliographyStyleAcm.mastersthesis(fmt, data)
end

function formatMisc(fmt::OutputFormat, style::Acm, data::BibInternal.Entry)
  BibliographyStyleAcm.misc(fmt, data)
end

function formatPhDThesis(fmt::OutputFormat, style::Acm, data::BibInternal.Entry)
  BibliographyStyleAcm.phdthesis(fmt, data)
end

function formatProceedings(fmt::OutputFormat, style::Acm, data::BibInternal.Entry)
  BibliographyStyleAcm.proceedings(fmt, data)
end

function formatTechreport(fmt::OutputFormat, style::Acm, data::BibInternal.Entry)
  BibliographyStyleAcm.techreport(fmt, data)
end

function formatUnpublished(fmt::OutputFormat, style::Acm, data::BibInternal.Entry)
  BibliographyStyleAcm.unpublished(fmt, data)
end
