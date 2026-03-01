```@meta
CurrentModule = BibFormatter
```

# BibFormatter

`BibFormatter.jl` converts parsed BibTeX entries into bibliography strings for multiple styles and output formats.

## User Interface

The main entry point is:

```julia
format(data::BibInternal.Entry; style::Symbol = :abbrv, fmt::Symbol = :text)::String
```

- `data`: one entry from `BibParser.parse_file(...)`
- `style`: bibliography style selector
- `fmt`: output formatter selector

### Minimal Example

```@example index_example
using BibParser
using BibFormatter

bibtex = """
@Article{Article,
  author  = {von Last, Junior, First Second and Last2, First2 Middle2 and Last3, First3 Middle3},
  title   = {This is a title.},
  journal = {Journal},
  year    = {yyyy},
  volume  = {v123},
  number  = {b234},
  pages   = {1-2},
  month   = {mm},
  note    = {This is a note},
  doi     = {10.1234/56.abc.123}
}
"""

bib = BibParser.parse_entry(bibtex)
entry = bib["Article"]

s = format(entry; style = :abbrvurl, fmt = :latex)
println(s)
```

## Available Styles

- `:abbrv`
- `:abbrvurl`
- `:acm`
- `:alpha` (alias of `:plain`)
- `:alphaurl`
- `:apalike`
- `:ieeetr`
- `:plain`
- `:plainurl`
- `:siam`
- `:unsrt` (alias of `:plain`)
- `:unsrturl`

## Available Output Formats

- `:latex`
- `:text`
- `:html`
- `:md`

All examples below use the same entry (`Article`, with a `doi` field) and style (`:abbrvurl`).

```@eval
using BibParser
using BibFormatter
using Markdown

bibtex = """
@Article{Article,
  author  = {von Last, Junior, First Second and Last2, First2 Middle2 and Last3, First3 Middle3},
  title   = {This is a title.},
  journal = {Journal},
  year    = {yyyy},
  volume  = {v123},
  number  = {b234},
  pages   = {1-2},
  month   = {mm},
  note    = {This is a note},
  doi     = {10.1234/56.abc.123}
}
"""
bib = BibParser.parse_entry(bibtex)
entry = bib["Article"]

latex = format(entry; style=:abbrvurl, fmt=:latex)
text = format(entry; style=:abbrvurl, fmt=:text)
html = format(entry; style=:abbrvurl, fmt=:html)
md = format(entry; style=:abbrvurl, fmt=:md)

parts = String[]
push!(parts, "### `:latex`")
push!(parts, "")
push!(parts, "```latex")
push!(parts, latex)
push!(parts, "```")
push!(parts, "")

push!(parts, "### `:text`")
push!(parts, "")
push!(parts, text)
push!(parts, "")

push!(parts, "### `:html`")
push!(parts, "")
push!(parts, "```html")
push!(parts, html)
push!(parts, "```")
push!(parts, "")

push!(parts, "### `:md`")
push!(parts, "")
push!(parts, "```markdown")
push!(parts, md)
push!(parts, "```")

Markdown.parse(join(parts, "\n"))
```
