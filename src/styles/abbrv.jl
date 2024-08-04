struct Abbrv <: BibliographyStyle end

formatAuthor(fmt::OutputFormat, style::Abbrv, von, last, junior, first, second) = formatAuthorFLast(fmt, von, last, junior, first, second)

formatPages(fmt::OutputFormat, style::Abbrv, pages::AbstractString) = joinNotEmpty(isMultiplePages(pages) ? "pages " : "page ",outputNumberRange(fmt,split(pages,'-')))

formatEditors(style::Abbrv, editors::AbstractString)::String = joinNotEmpty(editors,", ",isMultipleAuthors(editors) ? "editors" : "editor")

formatChapter(style::Abbrv, chapter::AbstractString, type::AbstractString)::String = joinNotEmpty(isempty(type) ? "chapter" : lowercase(type), " ", chapter)


# F. M. Last1, F. M. Last2, and F. M. Last3.
# Title.
# Journal, 123(234):1-2, mm yyyy.
# This is a note.
function formatArticle(fmt::OutputFormat, style::Abbrv, authors, title, journal, year; volume="", number="", pages="", month="", note="")
  blocks = []
  push!(blocks, authors)
  push!(blocks, title)

  let list = []
    push!(list, outputEmph(fmt,journal))
    pushNotEmpty!(list, formatVolumeNumberPagesCompact(volume,number,pages))
    push!(list, joinNotEmpty(month," ") * year)
    push!(blocks, join(list, ", "))
  end

  pushNotEmpty!(blocks, note)
  blocks
end

# F. M. Last1, F. M. Last2, and F. M. Last3.
# Title, volume v123 of Series.
# Publisher, Address, edition edition, mm yyyy.
# This is a note.
function formatBook(fmt::OutputFormat, style::Abbrv, title, publisher, year; authors="", editors="", volume="", number="", series="", address="", edition="", month="", note="")
  blocks = []
  if !isempty(authors)
    push!(blocks, authors)
  elseif !isempty(editors)
    push!(blocks, formatEditors(style,editors))
  end

  let list = []
    push!(list, outputEmph(fmt,title))
    pushNotEmpty!(list, joinNotEmpty("volume ",volume," of ",outputEmph(fmt,series)))
    push!(blocks, join(list, ", "))
  end

  let subblocks = []
    if isempty(volume)
      pushNotEmpty!(subblocks, joinNotEmpty("Number ",number," in ",series))
    end

    let list = []
      push!(list, publisher)
      pushNotEmpty!(list, address)
      pushNotEmpty!(list, joinNotEmpty("edition ",lowercase(edition)))
      push!(list, joinNotEmpty(month," ") * year)
      push!(subblocks, join(list, ", "))
    end
    push!(blocks, join(subblocks, ". "))
  end

  pushNotEmpty!(blocks, note)
  blocks
end

# F. M. Last1, F. M. Last2, and F. M. Last3.
# Title, chapter Chapter, pages 1-2.
# Number n234 in Series.
# Publisher, Address, edition edition, mm yyyy.
# This is a note.
function formatBooklet(fmt::OutputFormat, style::Abbrv, title; authors="", howpublished="", address="", month="", year="", note="")
  blocks = []
  pushNotEmpty!(blocks,authors)
  push!(blocks, title)

  let list = []
    pushNotEmpty!(list, howpublished)
    pushNotEmpty!(list, address)
    push!(list, joinNotEmpty(month," ") * year)
    push!(blocks, join(list, ", "))
  end

  pushNotEmpty!(blocks, note)
  blocks
end

# F. M. Last1, F. M. Last2, and F. M. Last3.
# Title, volume v123 of Series, chapter Chapter, pages 1-2.
# Publisher, Address, edition edition, mm yyyy.
# This is a note.
function formatInbook(fmt::OutputFormat, style::Abbrv, title, chapter, publisher, year; authors="", editors="", volume="", number="", series="", type="", address="", edition="", month="", pages="", note="")
  blocks = []
  if !isempty(authors)
    push!(blocks, authors)
  elseif !isempty(editors)
    push!(blocks, formatEditors(style,editors))
  end

  let list = []
    push!(list, outputEmph(fmt,title))
    pushNotEmpty!(list, joinNotEmpty("volume ",volume," of ",outputEmph(fmt,series)))
    pushNotEmpty!(list, formatChapter(style,chapter,type))
    pushNotEmpty!(list, formatPages(fmt,style,pages))
    push!(blocks, join(list, ", "))
  end

  let subblocks = []
    if isempty(volume)
      pushNotEmpty!(subblocks, joinNotEmpty("Number ",number," in ",series))
    end

    let list = []
      push!(list, publisher)
      pushNotEmpty!(list, address)
      pushNotEmpty!(list, joinNotEmpty("edition ",lowercase(edition)))
      push!(list, joinNotEmpty(month," ") * year)
      push!(subblocks, join(list, ", "))
    end
    push!(blocks, join(subblocks, ". "))
  end

  pushNotEmpty!(blocks, note)
  blocks
end

# F. M. Last1, F. M. Last2, and F. M. Last3.
# Title.
# In E. ELast1, E. ELast2, and E. ELast3, editors, Booktitle, volume v123 of Series, chapter Chapter, pages 1-2.
# Publisher, Address, edition edition, mm yyyy.
# This is a note.
function formatInCollection(fmt::OutputFormat, style::Abbrv, authors, title, booktitle, publisher, year; editors="", volume="", number="", series="", type="", chapter="", pages="", address="", edition="", month="", note="")
  blocks = []
  push!(blocks, authors)
  push!(blocks, title)

  let subblock = []
    let list = []
      pushNotEmpty!(list, formatEditors(style,editors))
      push!(list, outputEmph(fmt,booktitle))
      if !isempty(volume)
        pushNotEmpty!(list, joinNotEmpty("volume ",volume," of ",outputEmph(fmt,series)))
      elseif !isempty(number)
        pushNotEmpty!(list, joinNotEmpty("number ",number," in ",series))
      end
      pushNotEmpty!(list, formatChapter(style,chapter,type))
      pushNotEmpty!(list, formatPages(fmt,style,pages))
      push!(subblock, "In " * join(list, ", "))
    end

    let list = []
      push!(list, publisher)
      pushNotEmpty!(list, address)
      pushNotEmpty!(list, joinNotEmpty("edition ",edition))
      push!(list, joinNotEmpty(month," ") * year)
      push!(subblock, join(list, ", "))
    end

    push!(blocks, join(subblock, ". "))
  end

  pushNotEmpty!(blocks, note)
  blocks
end

# F. M. Last1, F. M. Last2, and F. M. Last3.
# Title.
# Organization, Address, edition edition, mm yyyy.
# This is a note.
function formatManual(fmt::OutputFormat, style::Abbrv, title, year; authors="", organization="", address="", edition="", month="", note="")
  blocks = []
  pushNotEmpty!(blocks,authors)
  push!(blocks, outputEmph(fmt,title))

  let list = []
    pushNotEmpty!(list, organization)
    pushNotEmpty!(list, address)
    pushNotEmpty!(list, joinNotEmpty("edition ",edition))
    push!(list, joinNotEmpty(month," ") * year)
    push!(blocks, join(list, ", "))
  end

  pushNotEmpty!(blocks, note)
  blocks
end

# F. M. Last.
# Title.
# Type, School, Address, mm yyyy.
# This is a note.
function formatMastersThesis(fmt::OutputFormat, style::Abbrv, author, title, school, year; type="", address="", month="", note="")
  blocks = []
  push!(blocks, author)
  push!(blocks, title)

  let list = []
    pushNotEmpty!(list, type)
    pushNotEmpty!(list, school)
    pushNotEmpty!(list, address)
    push!(list, joinNotEmpty(month," ") * year)
    push!(blocks, join(list, ", "))
  end

  pushNotEmpty!(blocks, note)
  blocks
end

# F. M. Last1, F. M. Last2, and F. M. Last3.
# Title.
# How it is published, mm yyyy.
# This is a note.
function formatMisc(fmt::OutputFormat, style::Abbrv; authors="", title="", howpublished="", month="", year="", note="")
  blocks = []
  pushNotEmpty!(blocks,authors)
  pushNotEmpty!(blocks, title)

  let list = []
    pushNotEmpty!(list, howpublished)
    push!(list, joinNotEmpty(month," ") * year)
    push!(blocks, join(list, ", "))
  end

  pushNotEmpty!(blocks, note)
  blocks
end

# F. M. Last.
# Title.
# Type, School, Address, mm yyyy.
# This is a note.
function formatPhDThesis(fmt::OutputFormat, style::Abbrv, author, title, school, year; type="", address="", month="", note="")
  blocks = []
  push!(blocks, author)
  push!(blocks, outputEmph(fmt,title))

  let list = []
    pushNotEmpty!(list, type)
    pushNotEmpty!(list, school)
    pushNotEmpty!(list, address)
    push!(list, joinNotEmpty(month," ") * year)
    push!(blocks, join(list, ", "))
  end

  pushNotEmpty!(blocks, note)
  blocks
end

# E. E. ELast1, E. E. ELast2, and E. E. ELast3, editors.
# Title, volume v123 of Series, Address, mm yyyy.
# Organization, Publisher.
# This is a note.
function formatProceedings(fmt::OutputFormat, style::Abbrv, title, year; editors="", volume="", number="", series="", organization="", address="", month="", publisher="", note="")
  blocks = []
  pushNotEmpty!(blocks, editors)

  let subblock = []
    let list = []
      push!(list, outputEmph(fmt,title))
      if !isempty(volume)
        pushNotEmpty!(list, joinNotEmpty("volume ",volume," of ",outputEmph(fmt,series)))
      elseif !isempty(number)
        pushNotEmpty!(list, joinNotEmpty("number ",number," in ",series))
      end
      pushNotEmpty!(list, address)
      push!(list, joinNotEmpty(month," ") * year)
      push!(subblock, join(list, ", "))
    end

    let list = []
      pushNotEmpty!(list, organization)
      pushNotEmpty!(list, publisher)
      push!(subblock, join(list, ", "))
    end

    pushNotEmpty!(blocks, join(subblock, ". "))
  end

  pushNotEmpty!(blocks, note)
  blocks
end

# F. M. Last1, F. M. Last2, and F. M. Last3.
# Title.
# Type n234, Institution, Address, mm yyyy.
# This is a note.
function formatTechreport(fmt::OutputFormat, style::Abbrv, authors, title, institution, year; type="", number="", address="", month="", note="")
  blocks = []
  push!(blocks, authors)
  push!(blocks, title)

  let list = []
    pushNotEmpty!(list, joinNotEmpty(uppercasefirst(type)," ") * number)
    pushNotEmpty!(list, institution)
    pushNotEmpty!(list, address)
    push!(list, joinNotEmpty(month," ") * year)
    push!(blocks, join(list, ", "))
  end

  pushNotEmpty!(blocks, note)
  blocks
end

# F. M. Last1, F. M. Last2, and F. M. Last3.
# Title.
# This is a note, mm yyyy.
function formatUnpublished(fmt::OutputFormat, style::Abbrv, authors, title, note; howpublished="", month="", year="")
  blocks = []
  push!(blocks, authors)
  push!(blocks, title)

  let list = []
    pushNotEmpty!(list, note)
    pushNotEmpty!(list, joinNotEmpty(month," ") * year)
    push!(blocks, join(list, ", "))
  end

  blocks
end