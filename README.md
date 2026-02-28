# BibFormatter

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://spraetor.github.io/BibFormatter.jl/stable/)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://spraetor.github.io/BibFormatter.jl/dev/)
[![Build Status](https://github.com/spraetor/BibFormatter.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/spraetor/BibFormatter.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Coverage](https://codecov.io/gh/spraetor/BibFormatter.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/spraetor/BibFormatter.jl)

## Usage
Convert a BibTeX entry from `BibParser` into a formatted bibliography block:

Assume we have a bibtex file `reference.bib` with entries like
```bibtex
@Article{Article,
  author  = {von Last, Junior, First Second and Last2, First2 Middle2 and Last3, First3 Middle3},
  title   = {This is a title.},
  journal = {Journal},
  year    = {yyyy},
  volume  = {v123},
  number  = {b234},
  pages   = {1-2},
  month   = {mm},
  note    = {This is a note}
}
```

This can be converted into a readable output

```julia
import BibParser
import BibFormatter

bibFile = BibParser.parse_file("references.bib")
println(BibFormatter.format(bibFile["Article"], style=:abbrv, fmt=:latex))
```
```latex
F.~S. von Last, Junior, F.~M. Last2, and F.~M. Last3.
\newblock This is a title.
\newblock {\em Journal}, v123(b234):1--2, mm yyyy.
\newblock This is a note.
```

Available bibliography styles:

- `:abbrv`
- `:acm`
- `:alpha` (alias of `:plain`)
- `:apalike`
- `:ieeetr`
- `:plain`
- `:siam`
- `:unsrt` (alias of `:plain`)

Available output formats:

- `:latex`
- `:text`
- `:html`
- `:md`

```julia
println(BibFormatter.format(bibFile["Article"], style=:abbrv, fmt=:text))
```
```
F. S. von Last, Junior, F. M. Last2, and F. M. Last3. This is a title. Journal, v123(b234):1-2, mm yyyy. This is a note.
```

```julia
println(BibFormatter.format(bibFile["Article"], style=:abbrv, fmt=:html))
```
```html
F.&nbsp;S. von Last, Junior, F.&nbsp;M. Last2, and F.&nbsp;M. Last3.
This is a title.
<em>Journal</em>, v123(b234):1&ndash;2, mm yyyy.
This is a note.
```
