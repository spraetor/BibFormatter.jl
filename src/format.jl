using Logging
import BibInternal


# Remove a trailing .
function formatTitle(style::BibliographyStyle, title::AbstractString)::String
  chopsuffix(title,".")
end

# F.~S. von Last, Junior
function formatAuthorFLast(von, last, junior, first, second)::String
  components = []
  pushNotEmpty!(components, abbreviateName(strip(first)))
  pushNotEmpty!(components, abbreviateName(strip(second)))
  pushNotEmpty!(components, joinNotEmpty(von," ") * last * joinNotEmpty(", ",junior))
  return join(components, " ")
end

# First~Second von Last, Junior
function formatAuthorFirstLast(von, last, junior, first, second)::String
  components = []
  pushNotEmpty!(components, strip(first))
  pushNotEmpty!(components, strip(second))
  pushNotEmpty!(components, joinNotEmpty(von," ") * last * joinNotEmpty(", ",junior))
  return join(components, " ")
end

# von Last, Junior, F.~S.
function formatAuthorLastF(von, last, junior, first, second)::String
  firstNames = []
  pushNotEmpty!(firstNames, abbreviateName(strip(first)))
  pushNotEmpty!(firstNames, abbreviateName(strip(second)))
  _first = join(firstNames, " ")

  components = []
  pushNotEmpty!(components, joinNotEmpty(von," ") * last)
  pushNotEmpty!(components, junior)
  pushNotEmpty!(components, _first)
  return join(components, ", ")
end

# von Last, Junior, First~Second
function formatAuthorLastFirst(von, last, junior, first, second)::String
  firstNames = []
  pushNotEmpty!(firstNames, strip(first))
  pushNotEmpty!(firstNames, strip(second))
  _first = join(firstNames, " ")

  components = []
  pushNotEmpty!(components, joinNotEmpty(von," ") * last)
  pushNotEmpty!(components, junior)
  pushNotEmpty!(components, _first)
  return join(components, ", ")
end

# default author formatting
function formatAuthor(style::BibliographyStyle, von, last, junior, first, second)::String
  formatAuthorFLast(von, last, junior, first, second)
end

# default author delimiting symbol
authorDelimStyle(style::BibliographyStyle) = ","

# format a list of authors
function formatAuthors(style::BibliographyStyle, names::BibInternal.Names)::String
  delim = authorDelimStyle(style) * " "
  lastDelim = (length(names) > 2 ? delim : " ") * "and "
  join(map((n) -> formatAuthor(style,n.particle,n.last,n.junior,n.first,n.middle), names), delim, lastDelim)
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


# default implementation of all bibtex entry types
formatArticle(style::BibliographyStyle, authors, title, journal, year; volume="", number="", pages="", month="", note="") = "not implemented"
formatBook(style::BibliographyStyle, title, publisher, year; authors="", editors="", volume="", number="", series="", address="", edition="", month="", note="") = "not implemented"
formatBooklet(style::BibliographyStyle, title; authors="", howpublished="", address="", month="", year="", note="") = "not implemented"
#formatConference(style::BibliographyStyle, authors, title, booktitle, year; editors="", volume="", number="", series="", pages="", address="", month="", organization="", publisher="", note="") = "not implemented"
formatInBook(style::BibliographyStyle, title, chapter, publisher, year; authors="", editors="", volume="", number="", series="", type="", address="", edition="", month="", pages="", note="") = "not implemented"
formatInCollection(style::BibliographyStyle, authors, title, booktitle, publisher, year; editors="", volume="", number="", series="", type="", chapter="", pages="", address="", edition="", month="", note="") = "not implemented"
#formatInProceedings(style::BibliographyStyle, authors, title, booktitle, year; editors="", volume="", number="", series="", pages="", address="", month="", organization="", publisher="") = "not implemented"
formatManual(style::BibliographyStyle, title, year; authors="", organization="", address="", edition="", month="", note="") = "not implemented"
formatMastersThesis(style::BibliographyStyle, author, title, school, year; type="", address="", month="", note="") = "not implemented"
formatMisc(style::BibliographyStyle; authors="", title="", howpublished="", month="", year="", note="") = "not implemented"
formatPhDThesis(style::BibliographyStyle, author, title, school, year; type="", address="", month="", note="") = "not implemented"
formatProceedings(style::BibliographyStyle, title, year; editors="", volume="", number="", series="", organization="", address="", month="", publisher="", note="") = "not implemented"
formatTechreport(style::BibliographyStyle, authors, title, institution, year; type="", number="", address="", month="", note="") = "not implemented"
formatUnpublished(style::BibliographyStyle, authors, title, note; howpublished="", month="", year="") = "not implemented"


function _format(style::BibliographyStyle, data::BibInternal.Entry)::String
  # preprocess some fields
  authors = formatAuthors(style, data.authors)
  editors = formatAuthors(style, data.editors)
  title = formatTitle(style, data.title)
  booktitle = formatTitle(style, data.booktitle)
  note = get(data.fields,"note","")
  if data.type == "article"
    checkRequiredFields("article", data.authors, data.title, data.in.journal, data.date.year)
    return formatArticle(style, authors, title, data.in.journal, data.date.year;
      volume=data.in.volume, number=data.in.number, pages=data.in.pages, month=data.date.month, note=note)
  elseif data.type == "book"
    checkRequiredFields("book", [data.authors; data.editors], data.title, data.in.publisher, data.date.year)
    return formatBook(style, title, data.in.publisher, data.date.year; authors=authors, editors=editors,
      volume=data.in.volume, number=data.in.number, series=data.in.series, address=data.in.address, edition=data.in.edition, month=data.date.month, note=note)
  elseif data.type == "booklet"
    checkRequiredFields("booklet", data.title)
    return formatBooklet(style, title; authors=authors, howpublished=data.access.howpublished,
      address=data.in.address, month=data.date.month, year=data.date.year, note=note)
  elseif data.type == "inbook"
    checkRequiredFields("inbook", [data.authors; data.editors], data.title, data.in.chapter * data.in.pages, data.in.publisher, data.date.year)
    return formatInbook(style, title, data.in.chapter, data.in.publisher, data.date.year; authors=authors,
      editors=editors, volume=data.in.volume, number=data.in.number, series=data.in.series,
      address=data.in.address, edition=data.in.edition, month=data.date.month, pages=data.in.pages, note=note)
  elseif data.type == "incollection"
    checkRequiredFields("incollection", data.authors, data.title, data.booktitle, data.in.publisher, data.date.year)
    return formatInCollection(style, authors, title, booktitle, data.in.publisher, data.date.year;
      editors=editors, volume=data.in.volume, number=data.in.number, series=data.in.series,
      chapter=data.in.chapter, pages=data.in.pages, address=data.in.address, edition=data.in.edition, month=data.date.month, note=note)
  elseif data.type == "manual"
    checkRequiredFields("manual", data.title, data.date.year)
    return formatManual(style, title, data.date.year;
      authors=authors, organization=data.in.organization, address=data.in.address, edition=data.in.edition, month=data.date.month, note=note)
  elseif data.type == "mastersthesis"
    checkRequiredFields("mastersthesis", data.authors, data.title, data.in.school, data.date.year)
    return formatMastersThesis(style, authors, title, data.in.school, data.date.year;
      type=data.type, address=data.in.address, month=data.date.month, note=note)
  elseif data.type == "misc"
    return formatMisc(style, authors=authors, title=title, howpublished=data.access.howpublished;
      month=data.date.month, year=data.date.year, note=note)
  elseif data.type == "phdthesis"
    checkRequiredFields("phdthesis", data.authors, data.title, data.in.school, data.date.year)
    return formatPhDThesis(style, authors, title, data.in.school, data.date.year;
      type=data.type, address=data.in.address, month=data.date.month, note=note)
  elseif data.type == "proceedings"
    checkRequiredFields("proceedings", data.title, data.date.year)
    return formatProceedings(style, title, data.date.year;
      editors=editors, volume=data.in.volume, number=data.in.number, series=data.in.series, address=data.in.address, month=data.date.month, publisher=data.in.publisher, note=note)
  elseif data.type == "techreport"
    checkRequiredFields("techreport", data.authors, data.title, data.in.institution, data.date.year)
    return formatTechreport(style, authors, title, data.in.institution, data.date.year;
      type=data.type, number=data.in.number, address=data.in.address, month=data.date.month, note=note)
  elseif data.type == "unpublished"
    checkRequiredFields("unpublished", data.authors, data.title, note)
    return formatUnpublished(style, authors, title, note;
      howpublished=data.access.howpublished, month=data.date.month, year=data.date.year)
  else
    @warn "bibliography type '$(data.type)' not yet implemented"
    return ""
  end
end