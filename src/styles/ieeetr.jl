struct Ieeetr <: BibliographyStyle end

formatAuthor(fmt::OutputFormat, style::Ieeetr, von, last, junior, first, second)::String = formatAuthorFLast(fmt, von, last, junior, first, second)

formatVolume(fmt::OutputFormat, style::Ieeetr, volume::AbstractString) = outputJoinSpace(fmt,["vol.",volume])
formatNumber(fmt::OutputFormat, style::Ieeetr, volume::AbstractString) = outputJoinSpace(fmt,["no.",volume])
formatPages(fmt::OutputFormat, style::Ieeetr, pages::AbstractString) = !isempty(pages) ? outputJoinSpace(fmt,["pp.",outputNumberRange(fmt,split(pages,'-'))]) : ""
formatEdition(fmt::OutputFormat, style::Ieeetr, edition::AbstractString) = !isempty(edition) ? outputJoinSpace(fmt,[lowercase(edition),"ed."]) : ""

formatEditors(style::Ieeetr, editors::AbstractString)::String = joinNotEmpty(editors,", ",isMultipleAuthors(editors) ? "eds." : "ed.")

formatChapter(style::Ieeetr, chapter::AbstractString, type::AbstractString)::String = joinNotEmpty(isempty(type) ? "chapter" : lowercase(type), " ", chapter)


# F.~S. von Last, Junior, F.~M. Last2, and F.~M. Last3, ``Title,'' {\em Journal}, vol.~v123, pp.~1--2, mm yyyy.
# This is a note.
function formatArticle(fmt::OutputFormat, style::Ieeetr, authors, title, journal, year; volume="", number="", pages="", month="", note="")
  blocks = []

  let list = []
    push!(list, authors)

    let sublist = []
      push!(sublist, outputQuote(fmt,title * ","))
      push!(sublist, emphFieldJournal(fmt,journal))
      push!(list, join(sublist, " "))
    end
    
    if !isempty(volume)
      push!(list, formatVolume(fmt,style,volume))
    end
    if !isempty(pages)
      push!(list, formatPages(fmt,style,pages))
    end
    push!(list, joinNotEmpty(month," ") * year)
    push!(blocks, join(list, ", "))
  end

  pushNotEmpty!(blocks, note)
  blocks
end

# F.~M. Last1, F.~M. Last2, and F.~M. Last3, {\em Title}, vol.~v123 of {\em Series}.
# Address: Publisher, edition~ed., mm yyyy.
# This is a note.
function formatBook(fmt::OutputFormat, style::Ieeetr, title, publisher, year; authors="", editors="", volume="", number="", series="", address="", edition="", month="", note="")
  blocks = []
  let list = []
    if !isempty(authors)
      push!(list, authors)
    elseif !isempty(editors)
      push!(list, formatEditors(style,editors))
    end

    push!(list, emphFieldTitle(fmt,title))
    if !isempty(volume) && !isempty(series)
      push!(list, formatVolume(fmt,style,volume) * " of " * emphFieldSeries(fmt,series))
    end
    push!(blocks, join(list, ", "))
  end

  let list = []
    if !isempty(number) && isempty(volume) && !isempty(series)
      push!(list, formatNumber(fmt,style,number) * " in " * series)
    end

    let sublist = []
      pushNotEmpty!(sublist, address)
      push!(sublist, publisher)
      push!(list, join(sublist, ": "))
    end

    pushNotEmpty!(list, formatEdition(fmt,style,edition))
    push!(list, joinNotEmpty(month," ") * year)
    push!(blocks, join(list, ", "))
  end

  pushNotEmpty!(blocks, note)
  blocks
end

# F.~M. Last1, F.~M. Last2, and F.~M. Last3, ``Title.'' How it is published, Address, mm yyyy.
# This is a note.
function formatBooklet(fmt::OutputFormat, style::Ieeetr, title; authors="", howpublished="", address="", month="", year="", note="")
  blocks = []
  let list = []
    pushNotEmpty!(list,authors)

    let sublist = []
      pushNotEmpty!(sublist, howpublished)
      pushNotEmpty!(sublist, address)
      push!(sublist, joinNotEmpty(month," ") * year)
      push!(list, outputQuote(fmt,title * ".") * " " * join(sublist, ", "))
    end
    push!(blocks, join(list, ", "))
  end

  pushNotEmpty!(blocks, note)
  blocks
end

# F.~M. Last1, F.~M. Last2, and F.~M. Last3, {\em This is a title}, vol.~v123 of {\em Series}, type Chapter, pp.~1--2.
# Address: Publisher, edition~ed., mm yyyy.
# This is a note.
function formatInbook(fmt::OutputFormat, style::Ieeetr, title, chapter, publisher, year; authors="", editors="", volume="", number="", series="", type="", address="", edition="", month="", pages="", note="")
  blocks = []
  let list = []
    if !isempty(authors)
      push!(list, authors)
    elseif !isempty(editors)
      push!(list, formatEditors(style,editors))
    end

    push!(list, emphFieldTitle(fmt,title))
    if !isempty(volume) && !isempty(series)
      push!(list, formatVolume(fmt,style,volume) * " of " * emphFieldSeries(fmt,series))
    end
    pushNotEmpty!(list, formatChapter(style,chapter,type))
    pushNotEmpty!(list, formatPages(fmt,style,pages))
    push!(blocks, join(list, ", "))
  end

  let list = []
    if !isempty(number) && isempty(volume) && !isempty(series)
      push!(list, formatNumber(fmt,style,number) * " in " * series)
    end

    let sublist = []
      pushNotEmpty!(sublist, address)
      push!(sublist, publisher)
      push!(list, join(sublist, ": "))
    end

    pushNotEmpty!(list, formatEdition(fmt,style,edition))
    push!(list, joinNotEmpty(month," ") * year)
    push!(blocks, join(list, ", "))
  end

  pushNotEmpty!(blocks, note)
  blocks
end

# F.~M. Last1, F.~M. Last2, and F.~M. Last3, ``Title,'' in {\em Booktitle} (E.~E. ELast1, E.~E. ELast2, and E.~E. ELast3, eds.), vol.~v123 of {\em Series}, type Chapter, pp.~1--2, Address: Publisher, edition~ed., mm yyyy.
# This is a note.
function formatInCollection(fmt::OutputFormat, style::Ieeetr, authors, title, booktitle, publisher, year; editors="", volume="", number="", series="", type="", chapter="", pages="", address="", edition="", month="", note="")
  blocks = []

  let list = []
    push!(list, authors)

    let sublist = []
      push!(sublist, outputQuote(fmt,title * ","))
      push!(sublist, "in " * emphFieldTitle(fmt,booktitle))
      pushNotEmpty!(sublist, joinNotEmpty("(",formatEditors(style,editors),")"))
      push!(list, join(sublist, " "))
    end
    
    if !isempty(volume) && !isempty(series)
      push!(list, formatVolume(fmt,style,volume) * " of " * emphFieldSeries(fmt,series))
    elseif !isempty(number) && !isempty(series)
      push!(list, formatNumber(fmt,style,volume) * " in " * series)
    end

    pushNotEmpty!(list, formatChapter(style,chapter,type))
    pushNotEmpty!(list, formatPages(fmt,style,pages))

    let sublist = []
      pushNotEmpty!(sublist, address)
      push!(sublist, publisher)
      push!(list, join(sublist, ": "))
    end

    pushNotEmpty!(list, formatEdition(fmt,style,edition))
    push!(list, joinNotEmpty(month," ") * year)
    push!(blocks, join(list, ", "))
  end

  pushNotEmpty!(blocks, note)
  blocks
end

# F.~M. Last1, F.~M. Last2, and F.~M. Last3, {\em Title}.
# Organization, Address, edition~ed., mm yyyy.
# This is a note.
function formatManual(fmt::OutputFormat, style::Ieeetr, title, year; authors="", organization="", address="", edition="", month="", note="")
  blocks = []
  let list = []
    pushNotEmpty!(list,authors)
    push!(list, emphFieldTitle(fmt,title))
    push!(blocks, join(list, ", "))
  end

  let list = []
    pushNotEmpty!(list, organization)
    pushNotEmpty!(list, address)
    pushNotEmpty!(list, formatEdition(fmt,style,edition))
    push!(list, joinNotEmpty(month," ") * year)
    push!(blocks, join(list, ", "))
  end

  pushNotEmpty!(blocks, note)
  blocks
end

# F.~M. Last, ``Title,'' type, School, Address, mm yyyy.
# This is a note.
function formatMastersThesis(fmt::OutputFormat, style::Ieeetr, author, title, school, year; type="", address="", month="", note="")
  blocks = []

  let list = []
    push!(list,author)

    let sublist = []
      pushNotEmpty!(sublist, type)
      pushNotEmpty!(sublist, school)
      pushNotEmpty!(sublist, address)
      push!(sublist, joinNotEmpty(month," ") * year)
      push!(list, outputQuote(fmt,title * ",") * " " * join(sublist, ", "))
    end
    push!(blocks, join(list, ", "))
  end
  
  pushNotEmpty!(blocks, note)
  blocks
end

# F.~M. Last1, F.~M. Last2, and F.~M. Last3, ``Title.'' How it is published, mm yyyy.
# This is a note.
function formatMisc(fmt::OutputFormat, style::Ieeetr; authors="", title="", howpublished="", month="", year="", note="")
  blocks = []

  let list = []
    pushNotEmpty!(list,authors)

    let sublist = []
      pushNotEmpty!(sublist, howpublished)
      push!(sublist, joinNotEmpty(month," ") * year)
      if !isempty(title)
        push!(list, outputQuote(fmt,title * ".") * " " * join(sublist, ", "))
      else
        push!(list, join(sublist, ", "))
      end
    end
    push!(blocks, join(list, ", "))
  end
  
  pushNotEmpty!(blocks, note)
  blocks
end

# F.~M. Last, {\em Title}.
# Type, School, Address, mm yyyy.
# This is a note.
function formatPhDThesis(fmt::OutputFormat, style::Ieeetr, author, title, school, year; type="", address="", month="", note="")
  blocks = []
  let list = []
    push!(list, author)
    push!(list, emphFieldTitle(fmt,title))
    push!(blocks, join(list, ", "))
  end

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

# E.~E. ELast1, E.~E. ELast2, and E.~E. ELast3, eds., {\em Title}, vol.~v123 of {\em Series}, (Address), Organization, Publisher, mm yyyy.
# This is a note.
function formatProceedings(fmt::OutputFormat, style::Ieeetr, title, year; editors="", volume="", number="", series="", organization="", address="", month="", publisher="", note="")
  blocks = []

  let list = []
    pushNotEmpty!(blocks, editors)
    push!(list, emphFieldTitle(fmt,title))
    if !isempty(volume) && !isempty(series)
      push!(list, formatVolume(fmt,style,volume) * " of " * emphFieldSeries(fmt,series))
    elseif !isempty(number) && !isempty(series)
      push!(list, formatNumber(fmt,style,volume) * " in " * series)
    end
    pushNotEmpty!(list, joinNotEmpty("(",address,")"))
    pushNotEmpty!(list, organization)
    pushNotEmpty!(list, publisher)
    push!(list, joinNotEmpty(month," ") * year)
    push!(blocks, join(list, ", "))
  end

  pushNotEmpty!(blocks, note)
  blocks
end

# F.~M. Last1, F.~M. Last2, and F.~M. Last3, ``Title,'' Type n234, Institution, Address, mm yyyy.
# This is a note.
function formatTechreport(fmt::OutputFormat, style::Ieeetr, authors, title, institution, year; type="", number="", address="", month="", note="")
  blocks = []

  let list = []
    push!(list,authors)

    let sublist = []
      pushNotEmpty!(sublist, joinNotEmpty(uppercasefirst(type)," ") * number)
      pushNotEmpty!(sublist, institution)
      pushNotEmpty!(sublist, address)
      push!(sublist, joinNotEmpty(month," ") * year)
      push!(list, outputQuote(fmt,title * ",") * " " * join(sublist, ", "))
    end
    push!(blocks, join(list, ", "))
  end
  
  pushNotEmpty!(blocks, note)
  blocks
end

# F.~M. Last1, F.~M. Last2, and F.~M. Last3, ``Title.'' This is a note, mm yyyy.
function formatUnpublished(fmt::OutputFormat, style::Ieeetr, authors, title, note; howpublished="", month="", year="")
  blocks = []

  let list = []
    push!(list,authors)

    let sublist = []
      pushNotEmpty!(sublist, note)
      push!(sublist, joinNotEmpty(month," ") * year)
      push!(list, outputQuote(fmt,title * ".") * " " * join(sublist, ", "))
    end
    push!(blocks, join(list, ", "))
  end
  
  blocks
end