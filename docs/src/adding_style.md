# Adding A New BST Style

This project translates BibTeX `.bst` style logic into Julia style modules.

## 1. Choose A Reference Template

Pick an existing translated style with similar complexity, for example:

- `src/styles/plain.jl`
- `src/styles/acm.jl`
- `src/styles/ieeetr.jl`

## 2. Create The Style File

Add `src/styles/<name>.jl` with:

- `struct <Name> <: BibliographyStyle end`
- a style module implementation with entry-formatting functions
- wrappers `formatArticle(..., style::<Name>, ...)`, etc.

## 3. Translate `.bst` Functions

Map key `.bst` helper functions into Julia helpers:

- name formatting helpers
- date, volume/number/pages helpers
- title/booktitle/in-proceedings helpers
- thesis/report helpers

Preserve punctuation and block transitions exactly; this is usually the hardest part.

## 4. Register The Style

In `src/BibFormatter.jl`:

- `include("styles/<name>.jl")`
- add `:<symbol> => <Name>()` to `styles`

## 5. Add Tests

Create `test/styles/<name>.jl` mirroring the existing style tests:

- compare rendered output against expected strings
- include representative entry kinds (`article`, `book`, `incollection`, `misc`, etc.)

Use generated `.bbl` outputs in `test/output/` as baseline references where available.

## 6. Update User Documentation

- add the style to `README.md`
- add examples in `docs/src/examples.md`
- mention special behavior in docs if it differs from related styles

## 7. Validate

Run:

```julia
using Pkg
Pkg.test()
```

Optionally build docs locally:

```bash
julia --project=docs docs/make.jl
```
