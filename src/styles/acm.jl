struct Acm <: BibliographyStyle end

formatAuthor(fmt::OutputFormat, style::Acm, von, last, junior, first, second)::String = formatAuthorLastF(fmt, von, last, junior, first, second)

formatVolume(fmt::OutputFormat, style::Acm, volume::AbstractString) = outputJoinSpace(fmt,["vol.",volume])
formatNumber(fmt::OutputFormat, style::Acm, volume::AbstractString) = outputJoinSpace(fmt,["no.",volume])
formatPages(fmt::OutputFormat, style::Acm, pages::AbstractString) = !isempty(pages) ? outputJoinSpace(fmt,["pp.",outputNumberRange(fmt,split(pages,'-'))]) : ""
formatEdition(fmt::OutputFormat, style::Acm, edition::AbstractString) = !isempty(edition) ? outputJoinSpace(fmt,[lowercase(edition),"ed."]) : ""

formatEditors(style::Acm, editors::AbstractString)::String = joinNotEmpty(editors,", ",isMultipleAuthors(editors) ? "Eds." : "Ed.")

formatChapter(style::Acm, chapter::AbstractString, type::AbstractString)::String = joinNotEmpty(isempty(type) ? "chapter" : lowercase(type), " ", chapter)


# {\sc von Last, Junior, F.~S., Last2, F.~M., and Last3, F.~M.}
# Title.
#{\em Journal v123}, b234 (mm yyyy), 1--2.
# This is a note.
function formatArticle(fmt::OutputFormat, style::Acm, authors, title, journal, year; volume="", number="", pages="", month="", note="")
  blocks = []
  push!(blocks, outputSmallCaps(fmt,authors))
  push!(blocks, title)

  let list = []
    let sublist = []
      push!(sublist, journal)
      pushNotEmpty!(sublist, volume)
      push!(list, outputEmph(fmt, join(sublist, " ")))
    end

    let sublist = []
      pushNotEmpty!(sublist, number)
      push!(list, "(" * joinNotEmpty(month," ") * year * ")")
      push!(list, join(sublist, " "))
    end

    pushNotEmpty!(list, outputNumberRange(fmt,split(pages,'-')))
    push!(blocks, join(list, ", "))
  end

  pushNotEmpty!(blocks, note)
  blocks
end

# {\sc Last1, F.~M., Last2, F.~M., and Last3, F.~M.}
# {\em Title}, edition~ed., vol.~v123 of {\em Series}.
# Publisher, Address, mm yyyy.
# This is a note.
function formatBook(fmt::OutputFormat, style::Acm, title, publisher, year; authors="", editors="", volume="", number="", series="", address="", edition="", month="", note="")
  blocks = []
  if !isempty(authors)
    push!(blocks, outputSmallCaps(fmt,authors))
  elseif !isempty(editors)
    push!(blocks, formatEditors(style,outputSmallCaps(fmt,editors)))
  end

  let list = []
    push!(list, outputEmph(fmt,title))
    pushNotEmpty!(list, formatEdition(fmt,style,edition))

    if !isempty(volume) && !isempty(series)
      push!(list, formatVolume(fmt,style,volume) * " of " * outputEmph(fmt,series))
    end
    push!(blocks, join(list, ", "))
  end

  let subblocks = []
    if !isempty(number) && isempty(volume) && !isempty(series)
      push!(subblocks, formatNumber(fmt,style,number) * " in " * series)
    end

    let list = []
      push!(list, publisher)
      pushNotEmpty!(list, address)
      push!(list, joinNotEmpty(month," ") * year)
      push!(subblocks, join(list, ", "))
    end

    push!(blocks, join(subblocks, ". "))
  end

  pushNotEmpty!(blocks, note)
  blocks
end

# {\sc Last1, F.~M., Last2, F.~M., and Last3, F.~M.}
# Title.
# How it is published, Address, mm yyyy.
# This is a note.
function formatBooklet(fmt::OutputFormat, style::Acm, title; authors="", howpublished="", address="", month="", year="", note="")
  blocks = []
  push!(blocks, outputSmallCaps(fmt,authors))
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

# {\sc Last1, F.~M., Last2, F.~M., and Last3, F.~M.}
# {\em This is a title}, edition~ed., vol.~v123 of {\em Series}.
# Publisher, Address, mm yyyy, type Chapter, pp.~1--2.
# This is a note.
function formatInbook(fmt::OutputFormat, style::Acm, title, chapter, publisher, year; authors="", editors="", volume="", number="", series="", type="", address="", edition="", month="", pages="", note="")
  blocks = []
  if !isempty(authors)
    push!(blocks, outputSmallCaps(fmt,authors))
  elseif !isempty(editors)
    push!(blocks, formatEditors(style,outputSmallCaps(fmt,editors)))
  end

  let list = []
    push!(list, outputEmph(fmt,title))
    pushNotEmpty!(list, formatEdition(fmt,style,edition))

    if !isempty(volume) && !isempty(series)
      push!(list, formatVolume(fmt,style,volume) * " of " * outputEmph(fmt,series))
    end

    push!(blocks, join(list, ", "))
  end

  let subblockes = []
    if !isempty(number) && isempty(volume) && !isempty(series)
      push!(subblockes, formatNumber(fmt,style,number) * " in " * series)
    end

    let list = []
      pushNotEmpty!(list, publisher)
      pushNotEmpty!(list, address)
      push!(list, joinNotEmpty(month," ") * year)
      pushNotEmpty!(list, formatChapter(style,chapter,type))
      if !isempty(pages)
        push!(list, outputJoinSpace(fmt,["pp.",formatPages(fmt,style,pages)]))
      end
      push!(subblockes, join(list, ", "))
    end

    push!(blocks, join(subblockes, ". "))
  end

  pushNotEmpty!(blocks, note)
  blocks
end

# {\sc Last1, F.~M., Last2, F.~M., and Last3, F.~M.}
# Title.
# In {\em Booktitle}, E.~E. ELast1, E.~E. ELast2, and E.~E. ELast3, Eds., edition~ed., vol.~v123 of {\em Series}. Publisher, Address, mm yyyy,
# type Chapter, pp.~1--2.
# This is a note.
function formatInCollection(fmt::OutputFormat, style::Acm, authors, title, booktitle, publisher, year; editors="", volume="", number="", series="", type="", chapter="", pages="", address="", edition="", month="", note="")
  blocks = []
  push!(blocks, outputSmallCaps(fmt,authors))
  push!(blocks, title)

  let subblock = []
    let list = []
      push!(list, outputEmph(fmt,booktitle))
      pushNotEmpty!(list, formatEditors(style,editors))
      pushNotEmpty!(list, formatEdition(fmt,style,edition))
      if !isempty(volume) && !isempty(series)
        push!(list, formatVolume(fmt,style,volume) * " of " * outputEmph(fmt,series))
      elseif !isempty(number) && !isempty(series)
        push!(list, formatNumber(fmt,style,number) * " in " * series)
      end
      push!(subblock, "In " * join(list, ", "))
    end

    let list = []
      push!(list, publisher)
      pushNotEmpty!(list, address)
      push!(list, joinNotEmpty(month," ") * year)
      pushNotEmpty!(list, formatChapter(style,chapter,type))
      pushNotEmpty!(list, formatPages(fmt,style,pages))
      push!(subblock, join(list, ", "))
    end

    push!(blocks, join(subblock, ". "))
  end

  pushNotEmpty!(blocks, note)
  blocks
end

# {\sc Last1, F.~M., Last2, F.~M., and Last3, F.~M.}
# {\em Title}, edition~ed.
# Organization, Address, mm yyyy.
# This is a note.
function formatManual(fmt::OutputFormat, style::Acm, title, year; authors="", organization="", address="", edition="", month="", note="")
  blocks = []
  pushNotEmpty!(blocks, outputSmallCaps(fmt,authors))

  let list = []
    push!(list, outputEmph(fmt,title))
    pushNotEmpty!(list, formatEdition(fmt,style,edition))
    push!(blocks, join(list, ", "))
  end

  let list = []
    pushNotEmpty!(list, organization)
    pushNotEmpty!(list, address)
    push!(list, joinNotEmpty(month," ") * year)
    push!(blocks, join(list, ", "))
  end

  pushNotEmpty!(blocks, note)
  blocks
end

# {\sc Last, F.~M.}
# Title.
# Type, School, Address, mm yyyy.
# This is a note.
function formatMastersThesis(fmt::OutputFormat, style::Acm, author, title, school, year; type="", address="", month="", note="")
  blocks = []
  push!(blocks, outputSmallCaps(fmt,author))
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

# {\sc Last1, F.~M., Last2, F.~M., and Last3, F.~M.}
# Title.
# How it is published, mm yyyy.
# This is a note.
function formatMisc(fmt::OutputFormat, style::Acm; authors="", title="", howpublished="", month="", year="", note="")
  blocks = []
  pushNotEmpty!(blocks, outputSmallCaps(fmt,authors))
  pushNotEmpty!(blocks, title)

  let list = []
    pushNotEmpty!(list, howpublished)
    push!(list, joinNotEmpty(month," ") * year)
    push!(blocks, join(list, ", "))
  end

  pushNotEmpty!(blocks, note)
  blocks
end

# {\sc Last, F.~M.}
# Title.
# Type, School, Address, mm yyyy.
# This is a note.
function formatPhDThesis(fmt::OutputFormat, style::Acm, author, title, school, year; type="", address="", month="", note="")
  blocks = []
  push!(blocks, outputSmallCaps(fmt,author))
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

# {\sc ELast1, E.~E., ELast2, E.~E., and ELast3, E.~E.}, Eds.
# {\em Title} (Address, mm yyyy), vol.~v123 of {\em Series}, Organization, Publisher.
# This is a note.
function formatProceedings(fmt::OutputFormat, style::Acm, title, year; editors="", volume="", number="", series="", organization="", address="", month="", publisher="", note="")
  blocks = []
  pushNotEmpty!(blocks, formatEditors(style,outputSmallCaps(fmt,editors)))

  let list = []
    let sublist = []
      push!(sublist, outputEmph(fmt,title))

      let subsublist = []
        pushNotEmpty!(subsublist, address)
        push!(subsublist, joinNotEmpty(month," ") * year)
        push!(sublist, "(" * join(subsublist, ", ") * ")")
      end

      push!(list, join(sublist, " "))
    end

    if !isempty(volume) && !isempty(series)
      push!(list, formatVolume(fmt,style,volume) * " of " * outputEmph(fmt,series))
    elseif !isempty(number) && !isempty(series)
      push!(list, formatNumber(fmt,style,number) * " in " * series)
    end

    pushNotEmpty!(list, organization)
    pushNotEmpty!(list, publisher)
    push!(blocks, join(list, ", "))
  end

  pushNotEmpty!(blocks, note)
  blocks
end

# {\sc Last1, F.~M., Last2, F.~M., and Last3, F.~M.}
# Title.
# Type n234, Institution, Address, mm yyyy.
# This is a note.
function formatTechreport(fmt::OutputFormat, style::Acm, authors, title, institution, year; type="", number="", address="", month="", note="")
  blocks = []
  push!(blocks, outputSmallCaps(fmt,authors))
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

# {\sc Last1, F.~M., Last2, F.~M., and Last3, F.~M.}
# Title.
# This is a note, mm yyyy.
function formatUnpublished(fmt::OutputFormat, style::Acm, authors, title, note; howpublished="", month="", year="")
  blocks = []
  push!(blocks, outputSmallCaps(fmt,authors))
  push!(blocks, title)

  let list = []
    pushNotEmpty!(list, note)
    pushNotEmpty!(list, joinNotEmpty(month," ") * year)
    push!(blocks, join(list, ", "))
  end

  blocks
end