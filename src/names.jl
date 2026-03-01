"""
    splitTildeGivenNames(first, second) -> (firstnorm, secondnorm)

Normalize given-name parts by treating `~` as an additional separator between
first and middle names.

This works around BibParser behavior where `John~Paul` is parsed into
`first="John~Paul"` and `middle=""` instead of `first="John", middle="Paul"`.
"""
function splitTildeGivenNames(first, second)::Tuple{String,String}
  fparts = [strip(p) for p in split(strip(first), '~'; keepempty=false) if !isempty(strip(p))]
  sparts = [strip(p) for p in split(strip(second), '~'; keepempty=false) if !isempty(strip(p))]
  if isempty(fparts)
    return "", join(sparts, " ")
  end
  return fparts[1], join(vcat(fparts[2:end], sparts), " ")
end

"""Format one name as `F.~S. von Last, Junior`."""
function formatNameFLast(fmt::OutputFormat, von, last, junior, first, second)::String
  first, second = splitTildeGivenNames(first, second)
  firstNames = []
  pushNotEmpty!(firstNames, abbreviateName(strip(first)))
  pushNotEmpty!(firstNames, abbreviateName(strip(second)))
  _first = outputJoinSpace(fmt, firstNames)
  nfirst = length(firstNames)

  surname = joinNotEmpty(von, " ") * last * joinNotEmpty(", ", junior)
  if empty(_first)
    surname
  elseif empty(von) && nfirst == 1 && !occursin('-', _first)
    outputJoinSpace(fmt, [_first, surname])
  else
    _first * " " * surname
  end
end

"""Format one name as `First~Second von Last, Junior`."""
function formatNameFirstLast(fmt::OutputFormat, von, last, junior, first, second)::String
  first, second = splitTildeGivenNames(first, second)
  firstNames = []
  pushNotEmpty!(firstNames, strip(first))
  pushNotEmpty!(firstNames, strip(second))
  _first = outputJoinSpace(fmt, firstNames)

  components = []
  pushNotEmpty!(components, _first)
  pushNotEmpty!(components, joinNotEmpty(von, " ") * last * joinNotEmpty(", ", junior))
  join(components, " ")
end

"""Format one name as `von Last, Junior, F.~S.`."""
function formatNameLastF(fmt::OutputFormat, von, last, junior, first, second)::String
  first, second = splitTildeGivenNames(first, second)
  firstNames = []
  pushNotEmpty!(firstNames, abbreviateName(strip(first)))
  pushNotEmpty!(firstNames, abbreviateName(strip(second)))
  _first = outputJoinSpace(fmt, firstNames)

  components = []
  pushNotEmpty!(components, joinNotEmpty(von, " ") * last)
  pushNotEmpty!(components, junior)
  pushNotEmpty!(components, _first)
  join(components, ", ")
end

"""Format one name as `von Last, Junior, First~Second`."""
function formatNameLastFirst(fmt::OutputFormat, von, last, junior, first, second)::String
  first, second = splitTildeGivenNames(first, second)
  firstNames = []
  pushNotEmpty!(firstNames, strip(first))
  pushNotEmpty!(firstNames, strip(second))
  _first = outputJoinSpace(fmt, firstNames)

  components = []
  pushNotEmpty!(components, joinNotEmpty(von, " ") * last)
  pushNotEmpty!(components, junior)
  pushNotEmpty!(components, _first)
  join(components, ", ")
end

"""Format a name list in `F.~Last` order with BibTeX-style list separators."""
function formatNamesFLast(fmt::OutputFormat, names)::String
  out = ""
  numnames = length(names)
  for (i, n) in enumerate(names)
    t = formatNameFLast(fmt, n.particle, n.last, n.junior, n.first, n.middle) # {f.~}{vv~}{ll}{, jj}
    if i > 1
      if numnames - i > 0
        out *= ", " * t
      else
        if numnames > 2
          out *= ","
        end
        if t == "others"
          out *= " " * outputJoinSpace(fmt, ["et", "al."]) # et~al.
        else
          out *= " and " * t
        end
      end
    else
      out = t
    end
  end
  out
end
