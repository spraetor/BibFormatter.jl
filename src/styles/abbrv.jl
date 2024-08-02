struct Abbrv <: BibliographyStyle end

formatAuthor(style::Abbrv, first, middle, last)::String = formatAuthorFirstLast(first,middle,last)
authorDelimStyle(style::Abbrv) = ","

function formatArticle(style::Abbrv, authors, title, journal, year; volume="", number="", pages="", month="", note="") 
  vnp = formatVolumeNumberPagesCompact(volume,number,pages)
  return "$authors. $title. $journal, $vnp, $year."
end

function formatBook(style::Abbrv, title, publisher, year; authors="", editors="", volume="", number="", series="", address="", edition="", month="", note="")
  blocks = []
  if !isempty(authors)
    push!(blocks, authors)
  elseif !isempty(editors)
    push!(blocks, editors)
  end

  subblock1 = []
  push!(subblock1, title)
  pushNotEmpty!(subblock1, joinNotEmpty("volume ",volume," of ") * series)
  push!(blocks, join(subblock1, ", "))

  subblock2 = []
  push!(subblock2, publisher)
  pushNotEmpty!(subblock2, address)
  pushNotEmpty!(subblock2, joinNotEmpty("edition ",edition))
  push!(subblock2, joinNotEmpty(month," ") * year)
  push!(blocks, join(subblock2, ", "))

  pushNotEmpty!(blocks, note)
  return join(blocks,". ") * "."
end

function formatBooklet(style::Abbrv, title; authors="", howpublished="", address="", month="", year="", note="")
  blocks = []
  pushNotEmpty!(blocks,authors)
  push!(blocks, title)

  subblock = []
  pushNotEmpty!(subblock, howpublished)
  pushNotEmpty!(subblock, address)
  push!(subblock, joinNotEmpty(month," ") * year)
  push!(blocks, join(subblock, ", "))

  pushNotEmpty!(blocks, note)
  return join(blocks,". ") * "."
end

function formatInbook(style::Abbrv, title, chapter, publisher, year; authors="", editors="", volume="", number="", series="", type="", address="", edition="", month="", pages="", note="")
  blocks = []
  if !isempty(authors)
    push!(blocks, authors)
  elseif !isempty(editors)
    push!(blocks, editors)
  end
  
  subblock1 = []
  push!(subblock1, title)
  pushNotEmpty!(subblock1, joinNotEmpty("volume ",volume," of ") * series)
  pushNotEmpty!(subblock1, joinNotEmpty("chapter ",chapter))
  pushNotEmpty!(subblock1, joinNotEmpty(isMultiplePages(pages) ? "pages " : "page ",pages))
  push!(blocks, join(subblock1, ", "))

  subblock2 = []
  push!(subblock2, publisher)
  pushNotEmpty!(subblock2, address)
  pushNotEmpty!(subblock2, joinNotEmpty("edition ",edition))
  push!(subblock2, joinNotEmpty(month," ") * year)
  push!(blocks, join(subblock2, ", "))

  pushNotEmpty!(blocks, note)
  return join(blocks,". ") * "."
end

function formatICollection(style::Abbrv, authors, title, booktitle, publisher, year; editors="", volume="", number="", series="", type="", chapter="", pages="", address="", edition="", month="", note="")
  blocks = []
  push!(blocks, authors)
  push!(blocks, title)
    
  subblock1 = []
  pushNotEmpty!(subblock1, joinNotEmpty(editors,", ",isMultipleAuthors(editors) ? "editors" : "editor"))
  push!(subblock1, booktitle)
  pushNotEmpty!(subblock1, joinNotEmpty("volume ",volume," of ") * series)
  pushNotEmpty!(subblock1, joinNotEmpty("chapter ",chapter))
  pushNotEmpty!(subblock1, joinNotEmpty(isMultiplePages(pages) ? "pages " : "page ",pages))
  push!(blocks, "In " * join(subblock1, ", "))

  subblock2 = []
  push!(subblock2, publisher)
  pushNotEmpty!(subblock2, address)
  pushNotEmpty!(subblock2, joinNotEmpty("edition ",edition))
  push!(subblock2, joinNotEmpty(month," ") * year)
  push!(blocks, join(subblock2, ", "))

  pushNotEmpty!(blocks, note)
  return join(blocks,". ") * "."
end