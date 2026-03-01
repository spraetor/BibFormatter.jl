using Logging
import BibInternal

"""Push `s` into `a` only when `s` is non-empty."""
pushNotEmpty!(a::AbstractVector, s::AbstractString) = isempty(s) || push!(a,s)

"""Concatenate two strings only when both are non-empty."""
joinNotEmpty(s1::AbstractString, s2::AbstractString) = (!isempty(s1) && !isempty(s2)) ? s1 * s2 : ""
"""Variadic version of [`joinNotEmpty`](@ref) applied left-to-right."""
joinNotEmpty(s1::AbstractString, s2::AbstractString, s...) = joinNotEmpty(joinNotEmpty(s1,s2),s...)

"""Abbreviate a name token to its first character plus a trailing dot."""
function abbreviateName(str::AbstractString)
  s = strip(str)
  isempty(s) && return ""

  # Preserve pure LaTeX control-sequence names such as "{\ss}" as one initial.
  initial(part::AbstractString) = startswith(part, "{\\") && endswith(part, "}") ?
    part * "." :
    (!isempty(decodeLatexSpecialChars(part)) ? decodeLatexSpecialChars(part)[1] * "." : "")

  # Hyphenated first names should become "M.-K.".
  join(initial.(split(s, '-')), "-")
end

"""
Lowercase text while preserving segments enclosed in `{...}` unchanged.

This mirrors BibTeX title-case protection behavior used in `.bib` fields.
Nested braces are supported.
"""
function lowercaseProtected(str::AbstractString)::String
  buf = IOBuffer()
  depth = 0
  for c in str
    if c == '{'
      depth += 1
      print(buf, c)
    elseif c == '}'
      depth = max(0, depth - 1)
      print(buf, c)
    else
      print(buf, depth > 0 ? string(c) : lowercase(string(c)))
    end
  end
  String(take!(buf))
end

"""String-specific emptiness check."""
empty(str::AbstractString) = isempty(str)
"""Vector-specific emptiness check."""
empty(arr::AbstractVector) = length(arr) == 0
"""Check whether a string property on `BibInternal.Entry` is missing or empty."""
empty(data::BibInternal.Entry, key::Symbol) = !hasproperty(data,key) || empty(getproperty(data,key)::String)
"""Check whether a string value in a dictionary is missing or empty."""
empty(data::Dict{String,String}, key::String) = empty(get(data,key,""))

"""Warn when all relevant `misc` fields are empty and return whether data is non-empty."""
function emptyMiscCheck(data::BibInternal.Entry)::Bool
  if empty(data.authors) && empty(data.title) && empty(data.access.howpublished) &&
     empty(data.date.month) && empty(data.date.year) && empty(data.note)
    @warn "All relevant fields are empty in $(data.id)."
    false
  else
    true
  end
end
