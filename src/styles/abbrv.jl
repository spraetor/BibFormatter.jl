struct Abbrv <: BibliographyStyle end

formatAuthor(style::Abbrv, von, last, junior, first, second)::String = formatAuthorFirstLast(von, last, junior, first, second)
authorDelimStyle(style::Abbrv) = ","

formatPages(_::Abbrv, pages::AbstractString)::String = joinNotEmpty(isMultiplePages(pages) ? "pages " : "page ",pages)
formatEditors(_::Abbrv, editors::AbstractString)::String = joinNotEmpty(editors,", ",isMultipleAuthors(editors) ? "editors" : "editor")
formatChapter(_::Abbrv, chapter::AbstractString, type::AbstractString)::String = joinNotEmpty(isempty(type) ? "chapter" : lowercase(type), " ", chapter)

# F. M. Last1, F. M. Last2, and F. M. Last3.
# Title.
# Journal, v123(b234):1-2, mm yyyy.
# This is a note.
function formatArticle(style::Abbrv, authors, title, journal, year; volume="", number="", pages="", month="", note="")
  blocks = []
  push!(blocks, authors)
  push!(blocks, title)

  subblock1 = []
  push!(subblock1, journal)
  pushNotEmpty!(subblock1, formatVolumeNumberPagesCompact(volume,number,pages))
  push!(subblock1, joinNotEmpty(month," ") * year)
  push!(blocks, join(subblock1, ", "))

  pushNotEmpty!(blocks, note)
  return join(blocks,". ") * "."
end

# F. M. Last1, F. M. Last2, and F. M. Last3.
# Title, volume v123 of Series.
# Publisher, Address, edition edition, mm yyyy.
# This is a note.
function formatBook(style::Abbrv, title, publisher, year; authors="", editors="", volume="", number="", series="", address="", edition="", month="", note="")
  blocks = []
  if !isempty(authors)
    push!(blocks, authors)
  elseif !isempty(editors)
    push!(blocks, formatEditors(style,editors))
  end

  subblock1 = []
  push!(subblock1, title)
  pushNotEmpty!(subblock1, joinNotEmpty("volume ",volume," of ",series))
  push!(blocks, join(subblock1, ", "))

  if isempty(volume)
    pushNotEmpty!(blocks, joinNotEmpty("Number ",number," in ",series))
  end

  subblock3 = []
  push!(subblock3, publisher)
  pushNotEmpty!(subblock3, address)
  pushNotEmpty!(subblock3, joinNotEmpty("edition ",lowercase(edition)))
  push!(subblock3, joinNotEmpty(month," ") * year)
  push!(blocks, join(subblock3, ", "))

  pushNotEmpty!(blocks, note)
  return join(blocks,". ") * "."
end

# F. M. Last1, F. M. Last2, and F. M. Last3.
# Title, chapter Chapter, pages 1-2.
# Number n234 in Series.
# Publisher, Address, edition edition, mm yyyy.
# This is a note.
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

# F. M. Last1, F. M. Last2, and F. M. Last3.
# Title, volume v123 of Series, chapter Chapter, pages 1-2.
# Publisher, Address, edition edition, mm yyyy.
# This is a note.
function formatInbook(style::Abbrv, title, chapter, publisher, year; authors="", editors="", volume="", number="", series="", type="", address="", edition="", month="", pages="", note="")
  blocks = []
  if !isempty(authors)
    push!(blocks, authors)
  elseif !isempty(editors)
    push!(blocks, formatEditors(style,editors))
  end

  subblock1 = []
  push!(subblock1, title)
  pushNotEmpty!(subblock1, joinNotEmpty("volume ",volume," of ",series))
  pushNotEmpty!(subblock1, formatChapter(style,chapter,type))
  pushNotEmpty!(subblock1, formatPages(style,pages))
  push!(blocks, join(subblock1, ", "))

  if isempty(volume)
    pushNotEmpty!(blocks, joinNotEmpty("Number ",number," in ",series))
  end

  subblock2 = []
  push!(subblock2, publisher)
  pushNotEmpty!(subblock2, address)
  pushNotEmpty!(subblock2, joinNotEmpty("edition ",lowercase(edition)))
  push!(subblock2, joinNotEmpty(month," ") * year)
  push!(blocks, join(subblock2, ", "))

  pushNotEmpty!(blocks, note)
  return join(blocks,". ") * "."
end

# F. M. Last1, F. M. Last2, and F. M. Last3.
# Title.
# In E. ELast1, E. ELast2, and E. ELast3, editors, Booktitle, volume v123 of Series, chapter Chapter, pages 1-2.
# Publisher, Address, edition edition, mm yyyy.
# This is a note.
function formatInCollection(style::Abbrv, authors, title, booktitle, publisher, year; editors="", volume="", number="", series="", type="", chapter="", pages="", address="", edition="", month="", note="")
  blocks = []
  push!(blocks, authors)
  push!(blocks, title)

  subblock1 = []
  pushNotEmpty!(subblock1, formatEditors(style,editors))
  push!(subblock1, booktitle)
  if !isempty(volume)
    pushNotEmpty!(subblock1, joinNotEmpty("volume ",volume," of ",series))
  elseif !isempty(number)
    pushNotEmpty!(subblock1, joinNotEmpty("number ",number," in ",series))
  end
  pushNotEmpty!(subblock1, formatChapter(style,chapter,type))
  pushNotEmpty!(subblock1, formatPages(style,pages))
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

# F. M. Last1, F. M. Last2, and F. M. Last3.
# Title.
# Organization, Address, edition edition, mm yyyy.
# This is a note.
function formatManual(style::Abbrv, title, year; authors="", organization="", address="", edition="", month="", note="")
  blocks = []
  pushNotEmpty!(blocks,authors)
  push!(blocks, title)

  subblock = []
  pushNotEmpty!(subblock, organization)
  pushNotEmpty!(subblock, address)
  pushNotEmpty!(subblock, joinNotEmpty("edition ",edition))
  push!(subblock, joinNotEmpty(month," ") * year)
  push!(blocks, join(subblock, ", "))

  pushNotEmpty!(blocks, note)
  return join(blocks,". ") * "."
end

# F. M. Last.
# Title.
# Type, School, Address, mm yyyy.
# This is a note.
function formatMastersThesis(style::Abbrv, author, title, school, year; type="", address="", month="", note="")
  blocks = []
  push!(blocks, author)
  push!(blocks, title)

  subblock = []
  pushNotEmpty!(subblock, type)
  pushNotEmpty!(subblock, school)
  pushNotEmpty!(subblock, address)
  push!(subblock, joinNotEmpty(month," ") * year)
  push!(blocks, join(subblock, ", "))

  pushNotEmpty!(blocks, note)
  return join(blocks,". ") * "."
end

# F. M. Last1, F. M. Last2, and F. M. Last3.
# Title.
# How it is published, mm yyyy.
# This is a note.
function formatMisc(style::Abbrv; authors="", title="", howpublished="", month="", year="", note="")
  blocks = []
  pushNotEmpty!(blocks,authors)
  pushNotEmpty!(blocks, title)

  subblock = []
  pushNotEmpty!(subblock, howpublished)
  push!(subblock, joinNotEmpty(month," ") * year)
  push!(blocks, join(subblock, ", "))

  pushNotEmpty!(blocks, note)
  return join(blocks,". ") * "."
end

# F. M. Last.
# Title.
# Type, School, Address, mm yyyy.
# This is a note.
function formatPhDThesis(style::Abbrv, author, title, school, year; type="", address="", month="", note="")
  blocks = []
  push!(blocks, author)
  push!(blocks, title)

  subblock = []
  pushNotEmpty!(subblock, type)
  pushNotEmpty!(subblock, school)
  pushNotEmpty!(subblock, address)
  push!(subblock, joinNotEmpty(month," ") * year)
  push!(blocks, join(subblock, ", "))

  pushNotEmpty!(blocks, note)
  return join(blocks,". ") * "."
end

# E. E. ELast1, E. E. ELast2, and E. E. ELast3, editors.
# Title, volume v123 of Series, Address, mm yyyy.
# Organization, Publisher.
# This is a note.
function formatProceedings(style::Abbrv, title, year; editors="", volume="", number="", series="", organization="", address="", month="", publisher="", note="")
  blocks = []
  pushNotEmpty!(blocks, editors)

  subblock1 = []
  push!(subblock1, title)
  if !isempty(volume)
    pushNotEmpty!(subblock1, joinNotEmpty("volume ",volume," of ",series))
  elseif !isempty(number)
    pushNotEmpty!(subblock1, joinNotEmpty("number ",number," in ",series))
  end
  pushNotEmpty!(subblock1, address)
  push!(subblock1, joinNotEmpty(month," ") * year)
  push!(blocks, join(subblock1, ", "))

  subblock2 = []
  pushNotEmpty!(subblock2, organization)
  pushNotEmpty!(subblock2, publisher)
  pushNotEmpty!(blocks, join(subblock2, ", "))

  pushNotEmpty!(blocks, note)
  return join(blocks,". ") * "."
end

# F. M. Last1, F. M. Last2, and F. M. Last3.
# Title.
# Type n234, Institution, Address, mm yyyy.
# This is a note.
function formatTechreport(style::Abbrv, authors, title, institution, year; type="", number="", address="", month="", note="")
  blocks = []
  push!(blocks, authors)
  push!(blocks, title)

  subblock = []
  pushNotEmpty!(subblock, joinNotEmpty(uppercasefirst(type)," ") * number)
  pushNotEmpty!(subblock, institution)
  pushNotEmpty!(subblock, address)
  push!(subblock, joinNotEmpty(month," ") * year)
  push!(blocks, join(subblock, ", "))

  pushNotEmpty!(blocks, note)
  return join(blocks,". ") * "."
end

# F. M. Last1, F. M. Last2, and F. M. Last3.
# Title.
# This is a note, mm yyyy.
function formatUnpublished(style::Abbrv, authors, title, note; howpublished="", month="", year="")
  blocks = []
  push!(blocks, authors)
  push!(blocks, title)

  subblock = []
  pushNotEmpty!(subblock, note)
  pushNotEmpty!(subblock, joinNotEmpty(month," ") * year)
  push!(blocks, join(subblock, ", "))

  return join(blocks,". ") * "."
end