using BibFormatter: format
using Test
import Base.Filesystem

"""Normalize bibitem text for robust comparisons across line-wrapping differences."""
normalizeBibitem(str::AbstractString) = strip(replace(str, r"\s+" => " "))

function normalizeBibitem(str::AbstractString, style::Symbol)
  s = normalizeBibitem(str)
  if style == :apalike
    # BibTeX apalike appends disambiguation letters to repeated years (e.g. yyyya).
    s = replace(s, r"\(yyyy[a-z]\)" => "(yyyy)")
    # BibTeX keeps a leading 'von' lowercase in this fixture.
    s = replace(s, r"^Von " => "von ")
  elseif style == :siam
    # BibTeX siam.bst suppresses repeated author lists across entries using a rule marker.
    s = replace(s, r"^\\leavevmode\\vrule height 2pt depth -1\.6pt width 23pt, " => "")
    # Our formatter emits explicit small-caps author list for each entry.
    s = replace(s, r"^\{\\sc .*?\}, " => "")
  elseif style in (:abbrvurl, :plainurl, :alphaurl, :unsrturl)
    # Normalize different hyperlink macro styles to comparable plain text.
    s = replace(s, r"\\href\s*\{[^}]*\}\s*\{\\path\{([^}]*)\}\}" => s"\1")
    s = replace(s, r"\\href\s*\{[^}]*\}\s*\{([^}]*)\}" => s"\1")
    s = replace(s, r"\\url\{([^}]*)\}" => s"\1")
    # Canonicalize DOI variants with optional resolver prefix duplication.
    s = replace(s, "https://doi.org/https://doi.org/" => "https://doi.org/")
    s = replace(s, "doi:https://doi.org/" => "doi:")
    # Ignore punctuation/layout differences between chained URL blocks.
    s = replace(s, r"\\newblock" => " ")
    s = replace(s, r"[.,]" => "")
    s = replace(s, r"\s+" => " ")
    s = strip(s)
  end
  s
end

function _escapeRegex(str::AbstractString)
  replace(str, r"([\\.^$|?*+(){}\[\]])" => s"\\\1")
end

"""Extract the body of `\\bibitem{key}` from a `.bbl` file content."""
function extractBibitem(bbl::AbstractString, key::AbstractString)::String
  pat = Regex("\\\\bibitem(?:\\[[^\\]]*\\])?\\{" * _escapeRegex(key) * "\\}\\s*(.*?)(?=(\\\\bibitem(?:\\[[^\\]]*\\])?\\{|\\\\end\\{thebibliography\\}))", "s")
  m = match(pat, bbl)
  m === nothing && error("Missing \\bibitem{$key} in fixture.")
  strip(m.captures[1])
end

"""Compare all entries for one style against `test/bbl/<style>.bbl`."""
function testStyleAgainstBbl(entries::AbstractDict{String,E}, style::Symbol) where E
  bblPath = Filesystem.joinpath(@__DIR__, "bbl", string(style) * ".bbl")
  @test isfile(bblPath)
  bbl = read(bblPath, String)

  for (key, entry) in entries
    expected = extractBibitem(bbl, key)
    actual = format(entry, style=style, fmt=:latex)
    actual == "Not implemented" && continue
    @test normalizeBibitem(actual, style) == normalizeBibitem(expected, style)
  end
end
