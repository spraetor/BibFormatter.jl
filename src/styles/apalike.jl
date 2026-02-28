struct Apalike <: BibliographyStyle end

module BibliographyStyleApalike

using ...BibFormatter: OutputFormat, dashify, empty, emphasize, formatNameLastF, outputAddPeriod, tieOrSpaceConnect
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

function outputYearCheck!(out::Output, data::BibInternal.Entry)
  if empty(data.date.year)
    @warn "Empty 'year' in $(data.id)"
  else
    lbl = get(data.fields, "extra.label", "")
    if out.state == BEFORE_ALL
      out.sentence = data.date.year * lbl
    else
      out.sentence *= " (" * data.date.year * lbl * ")"
    end
    out.state = MID_SENTENCE
  end
end

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


"""Format names in 'von Last, F.' order with apalike separators."""
function formatNames(out::Output, names::BibInternal.Names)::String
  s = ""
  numnames = length(names)
  for (i, n) in enumerate(names)
    t = formatNameLastF(out.fmt, n.particle, n.last, n.junior, n.first, n.middle) # {vv~}{ll}{, jj}{, f.}
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
"""Format author names for apalike entries."""
formatAuthors(out::Output, data::BibInternal.Entry)::String = empty(data.authors) ? "" : formatNames(out, data.authors)

"""Format editor names postfixed by 'editor(s)'."""
function formatEditors(out::Output, data::BibInternal.Entry)::String
  empty(data.editors) ? "" :
    formatNames(out, data.editors) * (length(data.editors) > 1 ? ", editors" : ", editor")
end

"""Use the BibTeX key only when the corresponding name list is empty."""
formatKey(data::BibInternal.Entry, names::BibInternal.Names)::String = empty(names) ? get(data.fields, "key", "") : ""
"""Convert title to sentence-case."""
formatTitle(out::Output, data::BibInternal.Entry)::String = empty(data.title) ? "" : uppercasefirst(lowercase(data.title))
"""Emphasize book-like titles."""
formatBTitle(out::Output, data::BibInternal.Entry)::String = emphasize(out.fmt, data.title)

"""Format 'volume V of series'."""
function formatBVolume(out::Output, data::BibInternal.Entry)::String
  if empty(data.in.volume)
    ""
  else
    s = tieOrSpaceConnect(out.fmt, ["volume", data.in.volume])
    if !empty(data.in.series)
      s *= " of " * emphasize(out.fmt, data.in.series)
    end
    if !empty(data.in.number)
      @warn "Can't use both 'volume' and 'number' in $(data.id)"
    end
    s
  end
end

"""Format 'number N in series' with sentence-aware capitalization."""
function formatNumberSeries(out::Output, data::BibInternal.Entry)::String
  if !empty(data.in.volume)
    ""
  elseif empty(data.in.number)
    data.in.series
  else
    s = tieOrSpaceConnect(out.fmt, [(out.state == MID_SENTENCE ? "number" : "Number"), data.in.number])
    if empty(data.in.series)
      @warn "There's a 'number' but no 'series' in $(data.id)"
    else
      s *= " in " * data.in.series
    end
    s
  end
end

"""Format edition as '<edition> edition' with sentence-aware capitalization."""
function formatEdition(out::Output, data::BibInternal.Entry)::String
  empty(data.in.edition) ? "" :
    (out.state == MID_SENTENCE ? lowercase(data.in.edition) : uppercasefirst(lowercase(data.in.edition))) * " edition"
end

"""Format pages as 'page P' or 'pages P1--P2'."""
function formatPages(out::Output, data::BibInternal.Entry)::String
  if empty(data.in.pages)
    ""
  else
    length(split(data.in.pages, r"[-,+]")) > 1 ?
      tieOrSpaceConnect(out.fmt, ["pages", dashify(out.fmt, data.in.pages)]) :
      tieOrSpaceConnect(out.fmt, ["page", data.in.pages])
  end
end

"""Format volume, number and pages as 'V(N):P'."""
function formatVolNumPages(out::Output, data::BibInternal.Entry)::String
  s = data.in.volume
  if !empty(data.in.number)
    s *= "($(data.in.number))"
    if empty(data.in.volume)
      @warn "There's a 'number' but no 'volume' in $(data.id)"
    end
  end
  if !empty(data.in.pages)
    s = empty(s) ? formatPages(out, data) : s * ":" * dashify(out.fmt, data.in.pages)
  end
  s
end

"""Format chapter and pages as 'chapter C, pages P'."""
function formatChapterPages(out::Output, data::BibInternal.Entry)::String
  if empty(data.in.chapter)
    formatPages(out, data)
  else
    pfx = empty(data.fields, "type") ? "chapter" : lowercase(data.fields["type"])
    s = tieOrSpaceConnect(out.fmt, [pfx, data.in.chapter])
    if !empty(data.in.pages)
      s *= ", " * formatPages(out, data)
    end
    s
  end
end

"""Format booktitle and optional editors as an 'In ...' phrase."""
function formatInEdBooktitle(out::Output, data::BibInternal.Entry)::String
  if empty(data.booktitle)
    ""
  else
    empty(data.editors) ?
      "In " * emphasize(out.fmt, data.booktitle) :
      "In " * formatEditors(out, data) * ", " * emphasize(out.fmt, data.booktitle)
  end
end

"""Use explicit thesis/report type field when present, otherwise fallback title."""
function formatThesisType(data::BibInternal.Entry, title::AbstractString)::String
  empty(data.fields, "type") ? title : uppercasefirst(lowercase(data.fields["type"]))
end

"""Format technical report type and number."""
function formatTrNumber(out::Output, data::BibInternal.Entry)::String
  t = empty(data.fields, "type") ? "Technical Report" : data.fields["type"]
  empty(data.in.number) ? uppercasefirst(lowercase(t)) : tieOrSpaceConnect(out.fmt, [t, data.in.number])
end


# TODO: crossref not implemented

function article(fmt::OutputFormat, data::BibInternal.Entry)
  out = Output(fmt)
  outputCheck!(out, formatAuthors(out, data), "Empty 'author' in $(data.id)")
  output!(out, formatKey(data, data.authors))
  outputYearCheck!(out, data)

  newBlock!(out)
  outputCheck!(out, formatTitle(out, data), "Empty 'title' in $(data.id)")

  newBlock!(out)
  outputCheck!(out, emphasize(out.fmt, data.in.journal), "Empty 'journal' in $(data.id)")
  output!(out, formatVolNumPages(out, data))

  newBlock!(out)
  output!(out, data.note)

  finEntry!(out)
end

function book(fmt::OutputFormat, data::BibInternal.Entry)
  out = Output(fmt)
  if empty(data.authors)
    outputCheck!(out, formatEditors(out, data), "Empty 'author' and 'editor' in $(data.id)")
    output!(out, formatKey(data, data.editors))
  else
    outputNonNull!(out, formatAuthors(out, data))
    if !empty(data.editors)
      @warn "Can't use both 'author' and 'editor' fields in $(data.id)"
    end
  end
  outputYearCheck!(out, data)

  newBlock!(out)
  outputCheck!(out, formatBTitle(out, data), "Empty 'title' in $(data.id)")
  output!(out, formatBVolume(out, data))

  newBlock!(out)
  output!(out, formatNumberSeries(out, data))

  newSentence!(out)
  outputCheck!(out, data.in.publisher, "Empty 'publisher' in $(data.id)")
  output!(out, data.in.address)
  output!(out, formatEdition(out, data))

  newBlock!(out)
  output!(out, data.note)

  finEntry!(out)
end

function booklet(fmt::OutputFormat, data::BibInternal.Entry)
  out = Output(fmt)
  output!(out, formatAuthors(out, data))
  output!(out, formatKey(data, data.authors))
  outputYearCheck!(out, data)

  newBlock!(out)
  outputCheck!(out, formatTitle(out, data), "Empty 'title' in $(data.id)")

  newBlock!(out)
  output!(out, data.access.howpublished)
  output!(out, data.in.address)

  newBlock!(out)
  output!(out, data.note)

  finEntry!(out)
end

function inbook(fmt::OutputFormat, data::BibInternal.Entry)
  out = Output(fmt)
  if empty(data.authors)
    outputCheck!(out, formatEditors(out, data), "Empty 'author' and 'editor' in $(data.id)")
    output!(out, formatKey(data, data.editors))
  else
    outputNonNull!(out, formatAuthors(out, data))
    if !empty(data.editors)
      @warn "Can't use both 'author' and 'editor' fields in $(data.id)"
    end
  end
  outputYearCheck!(out, data)

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

  newBlock!(out)
  output!(out, data.note)

  finEntry!(out)
end

function incollection(fmt::OutputFormat, data::BibInternal.Entry)
  out = Output(fmt)
  outputCheck!(out, formatAuthors(out, data), "Empty 'author' in $(data.id)")
  output!(out, formatKey(data, data.authors))
  outputYearCheck!(out, data)

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

  newBlock!(out)
  output!(out, data.note)

  finEntry!(out)
end

function inproceedings(fmt::OutputFormat, data::BibInternal.Entry)
  out = Output(fmt)
  outputCheck!(out, formatAuthors(out, data), "Empty 'author' in $(data.id)")
  output!(out, formatKey(data, data.authors))
  outputYearCheck!(out, data)

  newBlock!(out)
  outputCheck!(out, formatTitle(out, data), "Empty 'title' in $(data.id)")

  newBlock!(out)
  outputCheck!(out, formatInEdBooktitle(out, data), "Empty 'booktitle' in $(data.id)")
  output!(out, formatBVolume(out, data))
  output!(out, formatNumberSeries(out, data))
  output!(out, formatPages(out, data))
  output!(out, data.in.address)

  newSentence!(out)
  output!(out, data.in.organization)
  output!(out, data.in.publisher)

  newBlock!(out)
  output!(out, data.note)

  finEntry!(out)
end

conference(fmt::OutputFormat, data::BibInternal.Entry) = inproceedings(fmt, data)

function manual(fmt::OutputFormat, data::BibInternal.Entry)
  out = Output(fmt)
  output!(out, formatAuthors(out, data))
  output!(out, formatKey(data, data.authors))
  outputYearCheck!(out, data)

  newBlock!(out)
  outputCheck!(out, formatBTitle(out, data), "Empty 'title' in $(data.id)")

  newBlockCheck!(out, data.in.organization, data.in.address)
  output!(out, data.in.organization)
  output!(out, data.in.address)
  output!(out, formatEdition(out, data))

  newBlock!(out)
  output!(out, data.note)

  finEntry!(out)
end

function mastersthesis(fmt::OutputFormat, data::BibInternal.Entry)
  out = Output(fmt)
  outputCheck!(out, formatAuthors(out, data), "Empty 'author' in $(data.id)")
  output!(out, formatKey(data, data.authors))
  outputYearCheck!(out, data)

  newBlock!(out)
  outputCheck!(out, formatTitle(out, data), "Empty 'title' in $(data.id)")

  newBlock!(out)
  outputNonNull!(out, formatThesisType(data, "Master's thesis"))
  outputCheck!(out, data.in.school, "Empty 'school' in $(data.id)")
  output!(out, data.in.address)

  newBlock!(out)
  output!(out, data.note)

  finEntry!(out)
end

function misc(fmt::OutputFormat, data::BibInternal.Entry)
  out = Output(fmt)
  output!(out, formatAuthors(out, data))
  output!(out, formatKey(data, data.authors))
  outputYearCheck!(out, data)

  newBlock!(out)
  output!(out, formatTitle(out, data))

  newBlock!(out)
  output!(out, data.access.howpublished)

  newBlock!(out)
  output!(out, data.note)

  finEntry!(out)
end

function phdthesis(fmt::OutputFormat, data::BibInternal.Entry)
  out = Output(fmt)
  outputCheck!(out, formatAuthors(out, data), "Empty 'author' in $(data.id)")
  output!(out, formatKey(data, data.authors))
  outputYearCheck!(out, data)

  newBlock!(out)
  outputCheck!(out, formatBTitle(out, data), "Empty 'title' in $(data.id)")

  newBlock!(out)
  outputNonNull!(out, formatThesisType(data, "PhD thesis"))
  outputCheck!(out, data.in.school, "Empty 'school' in $(data.id)")
  output!(out, data.in.address)

  newBlock!(out)
  output!(out, data.note)

  finEntry!(out)
end

function proceedings(fmt::OutputFormat, data::BibInternal.Entry)
  out = Output(fmt)
  output!(out, formatEditors(out, data))
  output!(out, formatKey(data, data.editors))
  outputYearCheck!(out, data)

  newBlock!(out)
  outputCheck!(out, formatBTitle(out, data), "Empty 'title' in $(data.id)")
  output!(out, formatBVolume(out, data))
  output!(out, formatNumberSeries(out, data))
  output!(out, data.in.address)

  newSentence!(out)
  output!(out, data.in.organization)
  output!(out, data.in.publisher)

  newBlock!(out)
  output!(out, data.note)

  finEntry!(out)
end

function techreport(fmt::OutputFormat, data::BibInternal.Entry)
  out = Output(fmt)
  outputCheck!(out, formatAuthors(out, data), "Empty 'author' in $(data.id)")
  output!(out, formatKey(data, data.authors))
  outputYearCheck!(out, data)

  newBlock!(out)
  outputCheck!(out, formatTitle(out, data), "Empty 'title' in $(data.id)")

  newBlock!(out)
  outputNonNull!(out, formatTrNumber(out, data))
  outputCheck!(out, data.in.institution, "Empty 'institution' in $(data.id)")
  output!(out, data.in.address)

  newBlock!(out)
  output!(out, data.note)

  finEntry!(out)
end

function unpublished(fmt::OutputFormat, data::BibInternal.Entry)
  out = Output(fmt)
  outputCheck!(out, formatAuthors(out, data), "Empty 'author' in $(data.id)")
  output!(out, formatKey(data, data.authors))
  outputYearCheck!(out, data)

  newBlock!(out)
  outputCheck!(out, formatTitle(out, data), "Empty 'title' in $(data.id)")

  newBlock!(out)
  outputCheck!(out, data.note, "Empty 'note' in $(data.id)")

  finEntry!(out)
end

end # module BibliographyStyleApalike


function formatArticle(fmt::OutputFormat, style::Apalike, data::BibInternal.Entry)
  BibliographyStyleApalike.article(fmt, data)
end

function formatBook(fmt::OutputFormat, style::Apalike, data::BibInternal.Entry)
  BibliographyStyleApalike.book(fmt, data)
end

function formatBooklet(fmt::OutputFormat, style::Apalike, data::BibInternal.Entry)
  BibliographyStyleApalike.booklet(fmt, data)
end

function formatInBook(fmt::OutputFormat, style::Apalike, data::BibInternal.Entry)
  BibliographyStyleApalike.inbook(fmt, data)
end

function formatInCollection(fmt::OutputFormat, style::Apalike, data::BibInternal.Entry)
  BibliographyStyleApalike.incollection(fmt, data)
end

function formatManual(fmt::OutputFormat, style::Apalike, data::BibInternal.Entry)
  BibliographyStyleApalike.manual(fmt, data)
end

function formatMastersThesis(fmt::OutputFormat, style::Apalike, data::BibInternal.Entry)
  BibliographyStyleApalike.mastersthesis(fmt, data)
end

function formatMisc(fmt::OutputFormat, style::Apalike, data::BibInternal.Entry)
  BibliographyStyleApalike.misc(fmt, data)
end

function formatPhDThesis(fmt::OutputFormat, style::Apalike, data::BibInternal.Entry)
  BibliographyStyleApalike.phdthesis(fmt, data)
end

function formatProceedings(fmt::OutputFormat, style::Apalike, data::BibInternal.Entry)
  BibliographyStyleApalike.proceedings(fmt, data)
end

function formatTechreport(fmt::OutputFormat, style::Apalike, data::BibInternal.Entry)
  BibliographyStyleApalike.techreport(fmt, data)
end

function formatUnpublished(fmt::OutputFormat, style::Apalike, data::BibInternal.Entry)
  BibliographyStyleApalike.unpublished(fmt, data)
end
