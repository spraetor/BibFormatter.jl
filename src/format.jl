using Logging
import BibInternal


# Remove a trailing .
function formatTitle(style::BibliographyStyle, title::AbstractString)::String
  chopsuffix(title,".")
end

# F.~S. von Last, Junior
function formatAuthorFLast(fmt::OutputFormat, von, last, junior, first, second)::String
  firstNames = []
  pushNotEmpty!(firstNames, abbreviateName(strip(first)))
  pushNotEmpty!(firstNames, abbreviateName(strip(second)))
  _first = outputJoinSpace(fmt,firstNames)

  components = []
  pushNotEmpty!(components, _first)
  pushNotEmpty!(components, joinNotEmpty(von," ") * last * joinNotEmpty(", ",junior))
  return join(components, " ")
end

# First~Second von Last, Junior
function formatAuthorFirstLast(fmt::OutputFormat, von, last, junior, first, second)::String
  firstNames = []
  pushNotEmpty!(firstNames, strip(first))
  pushNotEmpty!(firstNames, strip(second))
  _first = outputJoinSpace(fmt,firstNames)

  components = []
  pushNotEmpty!(components, _first)
  pushNotEmpty!(components, joinNotEmpty(von," ") * last * joinNotEmpty(", ",junior))
  return join(components, " ")
end

# von Last, Junior, F.~S.
function formatAuthorLastF(fmt::OutputFormat, von, last, junior, first, second)::String
  firstNames = []
  pushNotEmpty!(firstNames, abbreviateName(strip(first)))
  pushNotEmpty!(firstNames, abbreviateName(strip(second)))
  _first = outputJoinSpace(fmt,firstNames)

  components = []
  pushNotEmpty!(components, joinNotEmpty(von," ") * last)
  pushNotEmpty!(components, junior)
  pushNotEmpty!(components, _first)
  return join(components, ", ")
end

# von Last, Junior, First~Second
function formatAuthorLastFirst(fmt::OutputFormat, von, last, junior, first, second)::String
  firstNames = []
  pushNotEmpty!(firstNames, strip(first))
  pushNotEmpty!(firstNames, strip(second))
  _first = outputJoinSpace(fmt,firstNames)

  components = []
  pushNotEmpty!(components, joinNotEmpty(von," ") * last)
  pushNotEmpty!(components, junior)
  pushNotEmpty!(components, _first)
  return join(components, ", ")
end

# default author formatting
function formatAuthor(fmt::OutputFormat, style::BibliographyStyle, von, last, junior, first, second)::String
  formatAuthorFLast(fmt, von, last, junior, first, second)
end

# default author delimiting symbol
authorDelimStyle(style::BibliographyStyle) = ","

# format a list of authors
function formatAuthors(fmt::OutputFormat, style::BibliographyStyle, names::BibInternal.Names)::String
  delim = authorDelimStyle(style) * " "
  lastDelim = (length(names) > 2 ? delim : " ") * "and "
  join(map((n) -> formatAuthor(fmt,style,n.particle,n.last,n.junior,n.first,n.middle), names), delim, lastDelim)
end

function formatVolumeNumber(volume::AbstractString, number::AbstractString)::String
  str = []
  pushNotEmpty!(str, volume)
  pushNotEmpty!(str, number)
  return join(str, ", ")
end

function formatVolumeNumberPagesNamed(volume::AbstractString, number::AbstractString, pages::AbstractString)::String
  str = []
  pushNotEmpty!(str, joinNotEmpty("vol. ",volume))
  pushNotEmpty!(str, joinNotEmpty("no. ",number))
  pushNotEmpty!(str, joinNotEmpty("pp. ",pages))
  return join(str, ", ")
end

function formatVolumeNumberPagesCompact(volume::AbstractString, number::AbstractString, pages::AbstractString)::String
  str = []
  pushNotEmpty!(str, joinNotEmpty(volume,"(",number,")"))
  pushNotEmpty!(str, pages)
  return join(str, ":")
end

formatBlock(fmt::OutputFormat, block::AbstractString) = outputAddPeriod(fmt, uppercasefirst(strip(block)))
formatBlocks(fmt::OutputFormat, style::BibliographyStyle, blocks::Nothing) = "Not implemented"
formatBlocks(fmt::OutputFormat, style::BibliographyStyle, blocks::AbstractVector{S}) where S = outputBlocks(fmt, map((b) -> formatBlock(fmt,b), blocks))


# default implementation of all bibtex entry types
formatArticle(fmt::OutputFormat, style::BibliographyStyle, data::BibInternal.Entry) = nothing
formatBook(fmt::OutputFormat, style::BibliographyStyle, data::BibInternal.Entry) = nothing
formatBooklet(fmt::OutputFormat, style::BibliographyStyle, data::BibInternal.Entry) = nothing
#formatConference(fmt::OutputFormat, style::BibliographyStyle, data::BibInternal.Entry) = nothing
formatInBook(fmt::OutputFormat, style::BibliographyStyle, data::BibInternal.Entry) = nothing
formatInCollection(fmt::OutputFormat, style::BibliographyStyle, data::BibInternal.Entry) = nothing
#formatInProceedings(fmt::OutputFormat, style::BibliographyStyle, data::BibInternal.Entry) = nothing
formatManual(fmt::OutputFormat, style::BibliographyStyle, data::BibInternal.Entry) = nothing
formatMastersThesis(fmt::OutputFormat, style::BibliographyStyle, data::BibInternal.Entry) = nothing
formatMisc(fmt::OutputFormat, style::BibliographyStyle, data::BibInternal.Entry) = nothing
formatPhDThesis(fmt::OutputFormat, style::BibliographyStyle, data::BibInternal.Entry) = nothing
formatProceedings(fmt::OutputFormat, style::BibliographyStyle, data::BibInternal.Entry) = nothing
formatTechreport(fmt::OutputFormat, style::BibliographyStyle, data::BibInternal.Entry) = nothing
formatUnpublished(fmt::OutputFormat, style::BibliographyStyle, data::BibInternal.Entry) = nothing


function _format(fmt::OutputFormat, style::BibliographyStyle, data::BibInternal.Entry)::String
  # preprocess some fields
  authors = formatAuthors(fmt, style, data.authors)
  editors = formatAuthors(fmt, style, data.editors)
  title = formatTitle(style, data.title)
  booktitle = formatTitle(style, data.booktitle)
  note = get(data.fields,"note","")
  blocks = nothing
  if data.type == "article"
    checkRequiredFields("article", data.authors, data.title, data.in.journal, data.date.year)
    blocks = formatArticle(fmt, style, authors, title, data.in.journal, data.date.year;
      volume=data.in.volume, number=data.in.number, pages=data.in.pages, month=data.date.month, note=note)
  elseif data.type == "book"
    checkRequiredFields("book", [data.authors; data.editors], data.title, data.in.publisher, data.date.year)
    blocks = formatBook(fmt, style, title, data.in.publisher, data.date.year; authors=authors, editors=editors,
      volume=data.in.volume, number=data.in.number, series=data.in.series, address=data.in.address, edition=data.in.edition, month=data.date.month, note=note)
  elseif data.type == "booklet"
    checkRequiredFields("booklet", data.title)
    blocks = formatBooklet(fmt, style, title; authors=authors, howpublished=data.access.howpublished,
      address=data.in.address, month=data.date.month, year=data.date.year, note=note)
  elseif data.type == "inbook"
    checkRequiredFields("inbook", [data.authors; data.editors], data.title, data.in.chapter * data.in.pages, data.in.publisher, data.date.year)
    blocks = formatInbook(fmt, style, title, data.in.chapter, data.in.publisher, data.date.year; authors=authors,
      editors=editors, volume=data.in.volume, number=data.in.number, series=data.in.series,
      address=data.in.address, edition=data.in.edition, month=data.date.month, pages=data.in.pages, note=note)
  elseif data.type == "incollection"
    checkRequiredFields("incollection", data.authors, data.title, data.booktitle, data.in.publisher, data.date.year)
    blocks = formatInCollection(fmt, style, authors, title, booktitle, data.in.publisher, data.date.year;
      editors=editors, volume=data.in.volume, number=data.in.number, series=data.in.series,
      chapter=data.in.chapter, pages=data.in.pages, address=data.in.address, edition=data.in.edition, month=data.date.month, note=note)
  elseif data.type == "manual"
    checkRequiredFields("manual", data.title, data.date.year)
    blocks = formatManual(fmt, style, title, data.date.year;
      authors=authors, organization=data.in.organization, address=data.in.address, edition=data.in.edition, month=data.date.month, note=note)
  elseif data.type == "mastersthesis"
    checkRequiredFields("mastersthesis", data.authors, data.title, data.in.school, data.date.year)
    blocks = formatMastersThesis(fmt, style, authors, title, data.in.school, data.date.year;
      type=data.type, address=data.in.address, month=data.date.month, note=note)
  elseif data.type == "misc"
    blocks = formatMisc(fmt, style, authors=authors, title=title, howpublished=data.access.howpublished;
      month=data.date.month, year=data.date.year, note=note)
  elseif data.type == "phdthesis"
    checkRequiredFields("phdthesis", data.authors, data.title, data.in.school, data.date.year)
    blocks = formatPhDThesis(fmt, style, authors, title, data.in.school, data.date.year;
      type=data.type, address=data.in.address, month=data.date.month, note=note)
  elseif data.type == "proceedings"
    checkRequiredFields("proceedings", data.title, data.date.year)
    blocks = formatProceedings(fmt, style, title, data.date.year;
      editors=editors, volume=data.in.volume, number=data.in.number, series=data.in.series, address=data.in.address, month=data.date.month, publisher=data.in.publisher, note=note)
  elseif data.type == "techreport"
    checkRequiredFields("techreport", data.authors, data.title, data.in.institution, data.date.year)
    blocks = formatTechreport(fmt, style, authors, title, data.in.institution, data.date.year;
      type=data.type, number=data.in.number, address=data.in.address, month=data.date.month, note=note)
  elseif data.type == "unpublished"
    checkRequiredFields("unpublished", data.authors, data.title, note)
    blocks = formatUnpublished(fmt, style, authors, title, note;
      howpublished=data.access.howpublished, month=data.date.month, year=data.date.year)
  else
    @warn "bibliography type '$(data.type)' not yet implemented"
  end

  return formatBlocks(fmt, style, blocks)
end



function _format2(fmt::OutputFormat, style::BibliographyStyle, data::BibInternal.Entry)::String
  blocks = if data.type == "article"
    formatArticle(fmt, style, data)
  elseif data.type == "book"
    formatBook(fmt, style, data)
  elseif data.type == "booklet"
    formatBooklet(fmt, style, data)
  elseif data.type == "inbook"
    formatInBook(fmt, style, data)
  elseif data.type == "incollection"
    formatInCollection(fmt, style, data)
  elseif data.type == "manual"
    formatManual(fmt, style, data)
  elseif data.type == "mastersthesis"
    formatMastersThesis(fmt, style, data)
  elseif data.type == "misc"
    formatMisc(fmt, style, data)
  elseif data.type == "phdthesis"
    formatPhDThesis(fmt, style, data)
  elseif data.type == "proceedings"
    formatProceedings(fmt, style, data)
  elseif data.type == "techreport"
    formatTechreport(fmt, style, data)
  elseif data.type == "unpublished"
    formatUnpublished(fmt, style, data)
  else
    @warn "bibliography type '$(data.type)' not yet implemented"
    nothing
  end

  formatBlocks(fmt, style, blocks)
end