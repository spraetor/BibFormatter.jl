using Logging
import BibInternal


# Remove a trailing .
function formatTitle(style::BibliographyStyle, title::AbstractString)::String
  chopsuffix(title,".")
end

function formatAuthorFirstLast(first, middle, last)::String
  firstNames = []
  pushNotEmpty!(firstNames, abbreviateName(strip(first)))
  pushNotEmpty!(firstNames, abbreviateName(strip(middle)))
  firstMiddle = join(firstNames, " ")
  return firstMiddle * " " * last
end

function formatAuthorLastFirst(first, middle, last)::String
  firstNames = []
  pushNotEmpty!(firstNames, abbreviateName(strip(first)))
  pushNotEmpty!(firstNames, abbreviateName(strip(middle)))
  firstMiddle = join(firstNames, " ")
  return last * ", " * firstMiddle
end

# default author formatting
function formatAuthor(style::BibliographyStyle, first, middle, last)::String 
  formatAuthorFirstLast(first,middle,last)
end

# default author delimiting symbol
authorDelimStyle(style::BibliographyStyle) = ","

# format a list of authors
function formatAuthors(style::BibliographyStyle, names::BibInternal.Names)::String
  delim = authorDelimStyle(style) * " "
  lastDelim = (length(names) > 2 ? delim : " ") * "and "
  join(map((n) -> formatAuthor(style,n.first,n.middle,n.last), names), delim, lastDelim)
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
formatConference(style::BibliographyStyle, authors, title, booktitle, year; editors="", volume="", number="", series="", pages="", address="", month="", organization="", publisher="", note="") = "not implemented"
formatInBook(style::BibliographyStyle, title, chapter, publisher, year; authors="", editors="", volume="", number="", series="", type="", address="", edition="", month="", pages="", note="") = "not implemented"
formatInCollection(style::BibliographyStyle, authors, title, booktitle, publisher, year; editors="", volume="", number="", series="", type="", chapter="", pages="", address="", edition="", month="", note="") = "not implemented"
formatInProceedings(style::BibliographyStyle, authors, title, booktitle, year; editors="", volume="", number="", series="", pages="", address="", month="", organization="", publisher="") = "not implemented"
formatManual(style::BibliographyStyle, title, year; authors="", organization="", address="", edition="", month="", note="") = "not implemented"
formatMastersThesis(style::BibliographyStyle, author, title, school, year; type="", address="", month="", note="") = "not implemented"
formatMisc(style::BibliographyStyle; authors="", title="", howpublished="", month="", year="", note="") = "not implemented"
formatPhDThesis(style::BibliographyStyle, author, title, school, year; type="", address="", month="", note="") = "not implemented"
formatProceedings(style::BibliographyStyle, title, year; editors="", volume="", number="", series="", address="", month="", publisher="") = "not implemented"
formatTechreport(style::BibliographyStyle, authors, title, institution, year; type="", number="", address="", month="", note="") = "not implemented"
formatUnpublished(style::BibliographyStyle, authors, title, note; month="", year="") = "not implemented"


function _format(style::BibliographyStyle, data::BibInternal.Entry)::String
  note = get(data.fields,"note","")
  if data.type == "article"
    checkRequiredFields("article", data.authors, data.title, data.in.journal, data.date.year)
    # preprocess some fields
    authors = formatAuthors(style, data.authors)
    title = formatTitle(style, data.title)
    return formatArticle(style, authors, title, data.in.journal, data.date.year; 
      volume=data.in.volume, number=data.in.number, pages=data.in.pages, month=data.date.month, note=note)
  elseif data.type == "book"
    checkRequiredFields("book", [data.authors; data.editors], data.title, data.in.publisher, data.date.year)
    # preprocess some fields
    authors = formatAuthors(style, data.authors)
    editors = formatAuthors(style, data.editors)
    title = formatTitle(style, data.title)
    return formatBook(style, title, data.in.publisher, data.date.year; authors=authors, editors=editors, 
      volume=data.in.volume, number=data.in.number, series=data.in.series, address=data.in.address, edition=data.in.edition, month=data.date.month, note=note)
  elseif data.type == "booklet"
    checkRequiredFields("booklet", data.title)
    # preprocess some fields
    authors = formatAuthors(style, data.authors)
    title = formatTitle(style, data.title)
    return formatBooklet(style, title; authors=authors, howpublished=data.access.howpublished, 
      address=data.in.address, month=data.date.month, year=data.date.year, note=note)
  elseif data.type == "inbook"
    checkRequiredFields("inbook", [data.authors; data.editors], data.title, data.in.chapter * data.in.pages, data.in.publisher, data.date.year)
    # preprocess some fields
    authors = formatAuthors(style, data.authors)
    editors = formatAuthors(style, data.editors)
    title = formatTitle(style, data.title)
    return formatInbook(style, title, data.in.chapter, data.in.publisher, data.date.year; authors=authors, 
      editors=editors, volume=data.in.volume, number=data.in.number, series=data.in.series, type=data.type, 
      address=data.in.address, edition=data.in.edition, month=data.date.month, pages=data.in.pages, note=note)
  elseif data.type == "incollection"
    checkRequiredFields("incollection", data.authors, data.title, data.booktitle, data.in.publisher, data.date.year)
    # preprocess some fields
    authors = formatAuthors(style, data.authors)
    editors = formatAuthors(style, data.editors)
    title = formatTitle(style, data.title)
    booktitle = formatTitle(style, data.booktitle)
    return formatInCollection(style, authors, title, booktitle, data.in.publisher, data.date.year; 
      editors=editors, volume=data.in.volume, number=data.in.number, series=data.in.series, type=data.type, 
      chapter=data.in.chapter, pages=data.in.pages, address=data.in.address, edition=data.in.edition, month=data.date.month, note=note)
  else
    @warn "bibliography type '$(data.type)' not yet implemented"
    return ""
  end
end