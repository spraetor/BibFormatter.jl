import BibInternal

abbreviateName(str::AbstractString) = str[1] * "."

function formatAuthor(name::BibInternal.Name, style::BibliographyStyles.T)
  firstNames = []
  isempty(strip(name.first)) || push!(firstNames, abbreviateName(strip(name.first)))
  isempty(strip(name.middle)) || push!(firstNames, abbreviateName(strip(name.middle)))
  first = join(firstNames, " ")
  if style in ( BibliographyStyles.abbrev, BibliographyStyles.alpha,
                BibliographyStyles.ieeetr, BibliographyStyles.plain,
                BibliographyStyles.siam, BibliographyStyles.unsrt )
    return first * " " * name.last
  elseif style in ( BibliographyStyles.acm, BibliographyStyles.apalike )
    return name.last * ", " * first
  end
end

authorDelimStyle(style::BibliographyStyles.T) = ","

function formatAuthors(names::BibInternal.Names, style::BibliographyStyles.T)::String
  delim = authorDelimStyle(style) * " "
  lastDelim = (length(names) > 2 ? delim : " ") * "and "
  join(map((n) -> formatAuthor(n,style), names), delim, lastDelim)
end

# Remove a trailing .
function formatTitle(title::AbstractString, style::BibliographyStyles.T)::String
  chopsuffix(title,".")
end

function formatVolumeNumber(data::BibInternal.In, style::BibliographyStyles.T)::String
  str = []
  isempty(data.volume) || push!(str, data.volume)
  isempty(data.number) || push!(str, data.number)
  return join(str, ", ")
end

function formatVolumeNumberPages(data::BibInternal.In, style::BibliographyStyles.T)::String
  str = []
  if style == BibliographyStyles.ieeetr
    isempty(data.volume) || push!(str, "vol. " * data.volume)
    isempty(data.number) || push!(str, "no. " * data.number)
    isempty(data.pages)  || push!(str, "pp. " * data.pages)
    return join(str, ", ")
  else
    volstr = ""
    isempty(data.volume) || (volstr *= data.volume)
    isempty(data.number) || (volstr *= "($(data.number))")
    push!(str, volstr)
    isempty(data.pages)  || push!(str, data.pages)
    return join(str, ":")
  end
end

function _format(data::BibInternal.Entry, style::BibliographyStyles.T)::String
  if data.type == "article"
    _authors = formatAuthors(data.authors, style)
    _title = formatTitle(data.title, style)
    _vn = formatVolumeNumber(data.in,style)
    _vnp = formatVolumeNumberPages(data.in,style)
    if style == BibliographyStyles.abbrev
      return "$(_authors). $(_title). $(data.in.journal), $(_vnp), $(data.date.year)."
    elseif style == BibliographyStyles.acm
      return "$(_authors) $(_title). $(data.in.journal) $(_vn) ($(data.date.year)), $(data.in.pages)."
    elseif style == BibliographyStyles.alpha
      return "$(_authors). $(_title). $(data.in.journal), $(_vnp), $(data.date.year)."
    elseif style == BibliographyStyles.apalike
      return "$(_authors) ($(data.date.year)). $(_title). $(data.in.journal), $(_vnp)."
    elseif style == BibliographyStyles.ieeetr
      return "$(_authors), ``$(_title),'' $(data.in.journal), $(_vnp), $(data.date.year)."
    elseif style == BibliographyStyles.plain
      return "$(_authors). $(_title). $(data.in.journal), $(_vnp), $(data.date.year)."
    elseif style == BibliographyStyles.siam
      return "$(_authors), $(_title), $(data.in.journal), $(data.in.volume) ($(data.date.year)), pp. $(data.in.pages)."
    elseif style == BibliographyStyles.unsrt
      return "$(_authors). $(_title). $(data.in.journal), $(_vnp), $(data.date.year)."
    else
      return "unknown"
    end
  else
    return "{$(data.type)}"
  end
end