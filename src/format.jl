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

function formatBlock(style::BibliographyStyle, block::AbstractString)
  out = uppercasefirst(strip(block))
  if endswith(out, ".") || endswith(out,".}") || endswith(out,">") # TODO: not a proper detection of all output formats
    return out
  else
    return out * "."
  end
end

function formatBlocks(style::BibliographyStyle, blocks::AbstractVector{S}) where S
  map((b) -> formatBlock(style,b), blocks)
end

# default implementation of all bibtex entry types
formatArticle(style::BibliographyStyle, authors, title, journal, year; volume="", number="", pages="", month="", note="") = nothing
formatBook(style::BibliographyStyle, title, publisher, year; authors="", editors="", volume="", number="", series="", address="", edition="", month="", note="") = nothing
formatBooklet(style::BibliographyStyle, title; authors="", howpublished="", address="", month="", year="", note="") = nothing
#formatConference(style::BibliographyStyle, authors, title, booktitle, year; editors="", volume="", number="", series="", pages="", address="", month="", organization="", publisher="", note="") = nothing
formatInBook(style::BibliographyStyle, title, chapter, publisher, year; authors="", editors="", volume="", number="", series="", type="", address="", edition="", month="", pages="", note="") = nothing
formatInCollection(style::BibliographyStyle, authors, title, booktitle, publisher, year; editors="", volume="", number="", series="", type="", chapter="", pages="", address="", edition="", month="", note="") = nothing
#formatInProceedings(style::BibliographyStyle, authors, title, booktitle, year; editors="", volume="", number="", series="", pages="", address="", month="", organization="", publisher="") = nothing
formatManual(style::BibliographyStyle, title, year; authors="", organization="", address="", edition="", month="", note="") = nothing
formatMastersThesis(style::BibliographyStyle, author, title, school, year; type="", address="", month="", note="") = nothing
formatMisc(style::BibliographyStyle; authors="", title="", howpublished="", month="", year="", note="") = nothing
formatPhDThesis(style::BibliographyStyle, author, title, school, year; type="", address="", month="", note="") = nothing
formatProceedings(style::BibliographyStyle, title, year; editors="", volume="", number="", series="", organization="", address="", month="", publisher="", note="") = nothing
formatTechreport(style::BibliographyStyle, authors, title, institution, year; type="", number="", address="", month="", note="") = nothing
formatUnpublished(style::BibliographyStyle, authors, title, note; howpublished="", month="", year="") = nothing


outputEmph(fmt::OutputFormat, str::AbstractString) = str
outputSmallCaps(fmt::OutputFormat, str::AbstractString) = str
outputQuote(fmt::OutputFormat, str::AbstractString) = "\"$str\""
outputJoinSpace(fmt::OutputFormat, list::AbstractVector{S}) where S = join(list, " ")
outputNumberRange(fmt::OutputFormat, pair::AbstractVector{S}) where {S<:AbstractString} = join(pair, "-")
outputBlocks(fmt::OutputFormat, blocks::Nothing) = "Not implemented"
outputBlocks(fmt::OutputFormat, blocks::AbstractVector{S}) where S = join(blocks, " ")


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

  return outputBlocks(fmt, formatBlocks(style, blocks))
end