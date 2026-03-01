struct Ieeetr <: BibliographyStyle end

module BibliographyStyleIeeetr

using ...BibFormatter: OutputFormat, dashify, empty, emptyMiscCheck, emphasize, formatNameFLast, lowercaseProtected, outputAddPeriod, outputTitleCase, outputQuote, replaceMonth, tieConnect, tieOrSpaceConnect
import BibInternal

@enum OutputState begin
  BEFORE_ALL
  MID_SENTENCE
  AFTER_QUOTE
  AFTER_SENTENCE
  AFTER_QUOTED_BLOCK
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
    if out.state == AFTER_QUOTE
      out.sentence *= " " * str
    else
      if out.state == AFTER_BLOCK
        addPeriod!(out)
        push!(out.blocks, out.sentence)
        out.sentence = str
      else
        if out.state == BEFORE_ALL
          out.sentence = str
        else
          if out.state == AFTER_QUOTED_BLOCK
            push!(out.blocks, out.sentence)
            out.sentence = str
          else
            addPeriod!(out)
            out.sentence *= " " * str
          end
        end
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

blankSep!(out::Output) = (out.state = AFTER_QUOTE)

function finEntry!(out::Output)
  if out.state != AFTER_QUOTED_BLOCK
    addPeriod!(out)
  end
  push!(out.blocks, out.sentence)
  out.blocks
end

function newBlock!(out::Output)
  if out.state != BEFORE_ALL
    out.state = out.state == AFTER_QUOTE ? AFTER_QUOTED_BLOCK : AFTER_BLOCK
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

"""Format names in 'F.~von Last' order with IEEE separators."""
function formatNames(out::Output, names::BibInternal.Names)::String
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
        if t == "others"
          s *= " " * emphasize(out.fmt, "et~al.")
        else
          s *= " and " * t
        end
      end
    else
      s = t
    end
  end
  s
end

"""Format author names for IEEE entries."""
formatAuthors(out::Output, data::BibInternal.Entry)::String = empty(data.authors) ? "" : formatNames(out, data.authors)

"""Format editor names postfixed by 'ed.' or 'eds.'."""
function formatEditors(out::Output, data::BibInternal.Entry)::String
  empty(data.editors) ? "" : formatNames(out, data.editors) * (length(data.editors) > 1 ? ", eds." : ", ed.")
end

"""Format article-like titles as quoted sentence-case text ending with a comma."""
function formatTitle(out::Output, data::BibInternal.Entry)::String
  empty(data.title) ? "" : outputQuote(out.fmt, outputTitleCase(out.fmt, uppercasefirst(lowercaseProtected(data.title))) * ",")
end

"""Format article-like titles as quoted sentence-case text ending with a period."""
function formatTitleP(out::Output, data::BibInternal.Entry)::String
  empty(data.title) ? "" : outputQuote(out.fmt, outputTitleCase(out.fmt, uppercasefirst(lowercaseProtected(data.title))) * ".")
end

"""Format date as '[mm ]yyyy'."""
function formatDate(out::Output, data::BibInternal.Entry)::String
  if empty(data.date.year)
    if empty(data.date.month)
      ""
    else
      @warn "There's a 'month' but no 'year' in $(data.id)"
      replaceMonth(data.date.month)
    end
  else
    empty(data.date.month) ? data.date.year : replaceMonth(data.date.month) * " " * data.date.year
  end
end

"""Emphasize book-like titles."""
formatBTitle(out::Output, data::BibInternal.Entry)::String = emphasize(out.fmt, data.title)

"""Format 'vol.~V of series'."""
function formatBVolume(out::Output, data::BibInternal.Entry)::String
  if empty(data.in.volume)
    ""
  else
    s = tieConnect(out.fmt, ["vol.", data.in.volume])
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
  if empty(data.in.volume)
    if empty(data.in.number)
      data.in.series
    else
      s = (out.state == MID_SENTENCE ? "no.~" : "No.~") * data.in.number
      if empty(data.in.series)
        @warn "There's a 'number' but no 'series' in $(data.id)"
      else
        s *= " in " * data.in.series
      end
      s
    end
  else
    ""
  end
end

"""Format edition postfixed by 'ed.'."""
formatEdition(out::Output, data::BibInternal.Entry)::String = empty(data.in.edition) ? "" : tieConnect(out.fmt, [lowercase(data.in.edition), "ed."])
"""Format pages as 'p.~P' or 'pp.~P1--P2'."""
formatPages(out::Output, data::BibInternal.Entry)::String = empty(data.in.pages) ? "" : (length(split(data.in.pages, r"[-,+]")) > 1 ? tieConnect(out.fmt, ["pp.", dashify(out.fmt, data.in.pages)]) : tieConnect(out.fmt, ["p.", data.in.pages]))
"""Format volume as 'vol.~V'."""
formatVolume(out::Output, data::BibInternal.Entry)::String = empty(data.in.volume) ? "" : tieConnect(out.fmt, ["vol.", data.in.volume])
"""Format number as 'no.~N'."""
formatNumber(out::Output, data::BibInternal.Entry)::String = empty(data.in.number) ? "" : tieConnect(out.fmt, ["no.", data.in.number])

"""Format chapter and pages as 'ch.~C, pp.~P'."""
function formatChapterPages(out::Output, data::BibInternal.Entry)::String
  if empty(data.in.chapter)
    formatPages(out, data)
  else
    s = empty(data.fields, "type") ? tieConnect(out.fmt, ["ch.", data.in.chapter]) : tieOrSpaceConnect(out.fmt, [lowercase(data.fields["type"]), data.in.chapter])
    if !empty(data.in.pages)
      s *= ", " * formatPages(out, data)
    end
    s
  end
end

"""Format booktitle and optional editors as an 'in ...' phrase."""
function formatInEdBooktitle(out::Output, data::BibInternal.Entry)::String
  if empty(data.booktitle)
    ""
  else
    s = "in " * emphasize(out.fmt, data.booktitle)
    if !empty(data.editors)
      s *= " (" * formatEditors(out, data) * ")"
    end
    s
  end
end

"""Use explicit thesis type field when present, with context-dependent casing."""
function formatThesisType(out::Output, data::BibInternal.Entry, title::AbstractString)::String
  if empty(data.fields, "type")
    title
  else
    out.state == AFTER_BLOCK ? uppercasefirst(lowercase(data.fields["type"])) : lowercase(data.fields["type"])
  end
end

"""Format technical report type and number."""
function formatTrNumber(out::Output, data::BibInternal.Entry)::String
  s = empty(data.fields, "type") ? "Tech. Rep." : data.fields["type"]
  empty(data.in.number) ? lowercase(s) : tieOrSpaceConnect(out.fmt, [s, data.in.number])
end

"""Format publisher and address as 'address: publisher'."""
function formatAddrPub(data::BibInternal.Entry)::String
  empty(data.in.publisher) ? "" : (empty(data.in.address) ? "" : data.in.address * ": ") * data.in.publisher
end

"""Format parenthesized address."""
formatPAddress(data::BibInternal.Entry)::String = empty(data.in.address) ? "" : "(" * data.in.address * ")"


# TODO: crossref not implemented

function article(fmt::OutputFormat, data::BibInternal.Entry)
  out = Output(fmt)
  outputCheck!(out, formatAuthors(out, data), "Empty 'author' in $(data.id)")
  outputCheck!(out, formatTitle(out, data), "Empty 'title' in $(data.id)")
  blankSep!(out)

  outputCheck!(out, emphasize(out.fmt, data.in.journal), "Empty 'journal' in $(data.id)")
  output!(out, formatVolume(out, data))
  if empty(data.date.month)
    output!(out, formatNumber(out, data))
  end
  output!(out, formatPages(out, data))
  outputCheck!(out, formatDate(out, data), "Empty 'year' in $(data.id)")

  newBlock!(out)
  output!(out, data.note)

  finEntry!(out)
end

function book(fmt::OutputFormat, data::BibInternal.Entry)
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

  newBlock!(out)
  output!(out, formatNumberSeries(out, data))
  outputCheck!(out, formatAddrPub(data), "Empty 'publisher' in $(data.id)")
  output!(out, formatEdition(out, data))
  outputCheck!(out, formatDate(out, data), "Empty 'year' in $(data.id)")

  newBlock!(out)
  output!(out, data.note)

  finEntry!(out)
end

function booklet(fmt::OutputFormat, data::BibInternal.Entry)
  out = Output(fmt)
  output!(out, formatAuthors(out, data))

  if empty(data.title)
    @warn "Empty 'title' in $(data.id)"
    newSentenceCheck!(out, data.access.howpublished)
  else
    if !empty(data.access.howpublished) || (empty(data.in.address) && empty(data.date.month) && empty(data.date.year))
      outputNonNull!(out, formatTitleP(out, data))
    else
      outputNonNull!(out, formatTitle(out, data))
    end
    blankSep!(out)
  end

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

  outputCheck!(out, formatBTitle(out, data), "Empty 'title' in $(data.id)")
  output!(out, formatBVolume(out, data))
  outputCheck!(out, formatChapterPages(out, data), "Empty 'chapter' and 'pages' in $(data.id)")

  newBlock!(out)
  output!(out, formatNumberSeries(out, data))
  outputCheck!(out, formatAddrPub(data), "Empty 'publisher' in $(data.id)")
  output!(out, formatEdition(out, data))
  outputCheck!(out, formatDate(out, data), "Empty 'year' in $(data.id)")

  newBlock!(out)
  output!(out, data.note)

  finEntry!(out)
end

function incollection(fmt::OutputFormat, data::BibInternal.Entry)
  out = Output(fmt)
  outputCheck!(out, formatAuthors(out, data), "Empty 'author' in $(data.id)")
  outputCheck!(out, formatTitle(out, data), "Empty 'title' in $(data.id)")
  blankSep!(out)

  outputCheck!(out, formatInEdBooktitle(out, data), "Empty 'booktitle' in $(data.id)")
  output!(out, formatBVolume(out, data))
  output!(out, formatNumberSeries(out, data))
  output!(out, formatChapterPages(out, data))
  outputCheck!(out, formatAddrPub(data), "Empty 'publisher' in $(data.id)")
  output!(out, formatEdition(out, data))
  outputCheck!(out, formatDate(out, data), "Empty 'year' in $(data.id)")

  newBlock!(out)
  output!(out, data.note)

  finEntry!(out)
end

function inproceedings(fmt::OutputFormat, data::BibInternal.Entry)
  out = Output(fmt)
  outputCheck!(out, formatAuthors(out, data), "Empty 'author' in $(data.id)")
  outputCheck!(out, formatTitle(out, data), "Empty 'title' in $(data.id)")
  blankSep!(out)

  outputCheck!(out, formatInEdBooktitle(out, data), "Empty 'booktitle' in $(data.id)")
  output!(out, formatBVolume(out, data))
  output!(out, formatNumberSeries(out, data))
  output!(out, formatPAddress(data))
  output!(out, formatPages(out, data))
  output!(out, data.in.organization)
  output!(out, data.in.publisher)
  outputCheck!(out, formatDate(out, data), "Empty 'year' in $(data.id)")

  newBlock!(out)
  output!(out, data.note)

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

  outputCheck!(out, formatBTitle(out, data), "Empty 'title' in $(data.id)")

  if empty(data.authors)
    if empty(data.in.organization)
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
  output!(out, data.note)

  finEntry!(out)
end

function mastersthesis(fmt::OutputFormat, data::BibInternal.Entry)
  out = Output(fmt)
  outputCheck!(out, formatAuthors(out, data), "Empty 'author' in $(data.id)")
  outputCheck!(out, formatTitle(out, data), "Empty 'title' in $(data.id)")
  blankSep!(out)

  outputNonNull!(out, formatThesisType(out, data, "Master's thesis"))
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

  if empty(data.title)
    newSentenceCheck!(out, data.access.howpublished)
  else
    if !empty(data.access.howpublished) || (empty(data.date.month) && empty(data.date.year))
      outputNonNull!(out, formatTitleP(out, data))
    else
      outputNonNull!(out, formatTitle(out, data))
    end
    blankSep!(out)
  end

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
  outputCheck!(out, formatBTitle(out, data), "Empty 'title' in $(data.id)")

  newBlock!(out)
  outputNonNull!(out, formatThesisType(out, data, "PhD thesis"))
  outputCheck!(out, data.in.school, "Empty 'school' in $(data.id)")
  output!(out, data.in.address)
  outputCheck!(out, formatDate(out, data), "Empty 'year' in $(data.id)")

  newBlock!(out)
  output!(out, data.note)

  finEntry!(out)
end

function proceedings(fmt::OutputFormat, data::BibInternal.Entry)
  out = Output(fmt)
  if empty(data.editors)
    output!(out, data.in.organization)
  else
    outputNonNull!(out, formatEditors(out, data))
  end

  outputCheck!(out, formatBTitle(out, data), "Empty 'title' in $(data.id)")
  output!(out, formatBVolume(out, data))
  output!(out, formatNumberSeries(out, data))
  output!(out, formatPAddress(data))

  if !empty(data.editors)
    output!(out, data.in.organization)
  end
  output!(out, data.in.publisher)
  outputCheck!(out, formatDate(out, data), "Empty 'year' in $(data.id)")

  newBlock!(out)
  output!(out, data.note)

  finEntry!(out)
end

function techreport(fmt::OutputFormat, data::BibInternal.Entry)
  out = Output(fmt)
  outputCheck!(out, formatAuthors(out, data), "Empty 'author' in $(data.id)")
  outputCheck!(out, formatTitle(out, data), "Empty 'title' in $(data.id)")
  blankSep!(out)

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
  outputCheck!(out, formatTitleP(out, data), "Empty 'title' in $(data.id)")
  blankSep!(out)

  outputCheck!(out, data.note, "Empty 'note' in $(data.id)")
  output!(out, formatDate(out, data))

  finEntry!(out)
end

end # module BibliographyStyleIeeetr


function formatArticle(fmt::OutputFormat, style::Ieeetr, data::BibInternal.Entry)
  BibliographyStyleIeeetr.article(fmt, data)
end

function formatBook(fmt::OutputFormat, style::Ieeetr, data::BibInternal.Entry)
  BibliographyStyleIeeetr.book(fmt, data)
end

function formatBooklet(fmt::OutputFormat, style::Ieeetr, data::BibInternal.Entry)
  BibliographyStyleIeeetr.booklet(fmt, data)
end

function formatInBook(fmt::OutputFormat, style::Ieeetr, data::BibInternal.Entry)
  BibliographyStyleIeeetr.inbook(fmt, data)
end

function formatInCollection(fmt::OutputFormat, style::Ieeetr, data::BibInternal.Entry)
  BibliographyStyleIeeetr.incollection(fmt, data)
end

function formatManual(fmt::OutputFormat, style::Ieeetr, data::BibInternal.Entry)
  BibliographyStyleIeeetr.manual(fmt, data)
end

function formatMastersThesis(fmt::OutputFormat, style::Ieeetr, data::BibInternal.Entry)
  BibliographyStyleIeeetr.mastersthesis(fmt, data)
end

function formatMisc(fmt::OutputFormat, style::Ieeetr, data::BibInternal.Entry)
  BibliographyStyleIeeetr.misc(fmt, data)
end

function formatPhDThesis(fmt::OutputFormat, style::Ieeetr, data::BibInternal.Entry)
  BibliographyStyleIeeetr.phdthesis(fmt, data)
end

function formatProceedings(fmt::OutputFormat, style::Ieeetr, data::BibInternal.Entry)
  BibliographyStyleIeeetr.proceedings(fmt, data)
end

function formatTechreport(fmt::OutputFormat, style::Ieeetr, data::BibInternal.Entry)
  BibliographyStyleIeeetr.techreport(fmt, data)
end

function formatUnpublished(fmt::OutputFormat, style::Ieeetr, data::BibInternal.Entry)
  BibliographyStyleIeeetr.unpublished(fmt, data)
end
