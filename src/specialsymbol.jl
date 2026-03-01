"""
Build exact-string replacement rules for LaTeX symbol commands.

For accent commands we support three common source encodings:
1. `{\\<cmd><x>}`
2. `\\<cmd>{<x>}`
3. `\\<cmd><x>`

For macro commands (e.g. `\\ae`, `\\ss`) we support:
1. `{\\<cmd>}`
2. `\\<cmd>{}`
3. `\\<cmd>`
"""
function _buildLatexSpecialReplacements()
  rules = Pair{String,String}[]

  accentRules = [
    ("\"", "a", "ä"),  # matches umlaut-a commands
    ("\"", "A", "Ä"),  # matches umlaut-A commands
    ("\"", "o", "ö"),  # matches umlaut-o commands
    ("\"", "O", "Ö"),  # matches umlaut-O commands
    ("\"", "u", "ü"),  # matches umlaut-u commands
    ("\"", "U", "Ü"),  # matches umlaut-U commands
    ("\"", "e", "ë"),  # matches umlaut-e commands
    ("\"", "E", "Ë"),  # matches umlaut-E commands
    ("\"", "i", "ï"),  # matches umlaut-i commands
    ("\"", "I", "Ï"),  # matches umlaut-I commands
    ("\"", "y", "ÿ"),  # matches umlaut-y commands
    ("\"", "Y", "Ÿ"),  # matches umlaut-Y commands

    ("'", "a", "á"),   # matches acute-a commands
    ("'", "A", "Á"),   # matches acute-A commands
    ("'", "e", "é"),   # matches acute-e commands
    ("'", "E", "É"),   # matches acute-E commands
    ("'", "i", "í"),   # matches acute-i commands
    ("'", "I", "Í"),   # matches acute-I commands
    ("'", "o", "ó"),   # matches acute-o commands
    ("'", "O", "Ó"),   # matches acute-O commands
    ("'", "u", "ú"),   # matches acute-u commands
    ("'", "U", "Ú"),   # matches acute-U commands
    ("'", "y", "ý"),   # matches acute-y commands
    ("'", "Y", "Ý"),   # matches acute-Y commands
    ("'", "n", "ń"),   # matches acute-n commands
    ("'", "N", "Ń"),   # matches acute-N commands
    ("'", "s", "ś"),   # matches acute-s commands
    ("'", "S", "Ś"),   # matches acute-S commands

    ("`", "a", "à"),   # matches grave-a commands
    ("`", "A", "À"),   # matches grave-A commands
    ("`", "e", "è"),   # matches grave-e commands
    ("`", "E", "È"),   # matches grave-E commands
    ("`", "i", "ì"),   # matches grave-i commands
    ("`", "I", "Ì"),   # matches grave-I commands
    ("`", "o", "ò"),   # matches grave-o commands
    ("`", "O", "Ò"),   # matches grave-O commands
    ("`", "u", "ù"),   # matches grave-u commands
    ("`", "U", "Ù"),   # matches grave-U commands

    ("^", "a", "â"),   # matches circumflex-a commands
    ("^", "A", "Â"),   # matches circumflex-A commands
    ("^", "e", "ê"),   # matches circumflex-e commands
    ("^", "E", "Ê"),   # matches circumflex-E commands
    ("^", "i", "î"),   # matches circumflex-i commands
    ("^", "I", "Î"),   # matches circumflex-I commands
    ("^", "o", "ô"),   # matches circumflex-o commands
    ("^", "O", "Ô"),   # matches circumflex-O commands
    ("^", "u", "û"),   # matches circumflex-u commands
    ("^", "U", "Û"),   # matches circumflex-U commands

    ("~", "a", "ã"),   # matches tilde-a commands
    ("~", "A", "Ã"),   # matches tilde-A commands
    ("~", "n", "ñ"),   # matches tilde-n commands
    ("~", "N", "Ñ"),   # matches tilde-N commands
    ("~", "o", "õ"),   # matches tilde-o commands
    ("~", "O", "Õ"),   # matches tilde-O commands
  ]

  for (cmd, letter, unicode) in accentRules
    push!(rules, "{\\" * cmd * letter * "}" => unicode)
    push!(rules, "\\" * cmd * "{" * letter * "}" => unicode)
    push!(rules, "\\" * cmd * letter => unicode)
  end

  # Cedilla uses nested braces in its common TeX encoding.
  push!(rules, "{\\c{c}}" => "ç")  # matches braced cedilla-c
  push!(rules, "\\c{c}" => "ç")    # matches unbraced cedilla-c
  push!(rules, "{\\c{C}}" => "Ç")  # matches braced cedilla-C
  push!(rules, "\\c{C}" => "Ç")    # matches unbraced cedilla-C
  push!(rules, "{\\&}" => "&")     # matches braced escaped ampersand
  push!(rules, "\\&{}" => "&")     # matches escaped ampersand with empty braces
  push!(rules, "\\&" => "&")       # matches escaped ampersand

  macroRules = [
    ("oe", "œ"),  # matches oe ligature commands
    ("OE", "Œ"),  # matches OE ligature commands
    ("o", "ø"),   # matches slashed-o commands
    ("O", "Ø"),   # matches slashed-O commands
    ("l", "ł"),   # matches stroked-l commands
    ("L", "Ł"),   # matches stroked-L commands
    ("ae", "æ"),  # matches ae ligature commands
    ("AE", "Æ"),  # matches AE ligature commands
    ("aa", "å"),  # matches ring-a commands
    ("AA", "Å"),  # matches ring-A commands
    ("ss", "ß"),  # matches sharp-s commands
  ]

  for (cmd, unicode) in macroRules
    push!(rules, "{\\" * cmd * "}" => unicode)
    push!(rules, "\\" * cmd * "{}" => unicode)
    push!(rules, "\\" * cmd => unicode)
  end

  rules
end

const _latexSpecialReplacements = _buildLatexSpecialReplacements()

"""Return index of the next unescaped `\$` delimiter or `nothing`."""
function _findUnescapedDollar(str::AbstractString, start::Int)
  i = start
  while i <= lastindex(str)
    if str[i] == '$'
      # A dollar is escaped when preceded by an odd number of backslashes.
      bs = 0
      j = prevind(str, i)
      while j >= firstindex(str) && str[j] == '\\'
        bs += 1
        j = j == firstindex(str) ? 0 : prevind(str, j)
      end
      iseven(bs) && return i
    end
    i = nextind(str, i)
  end
  nothing
end

"""
    protectMathBlocks(str) -> (masked, placeholders)

Replace `\$...\$` and `\\(...\\)` math blocks by UUID placeholders so text-level
symbol replacement can run safely outside math content.
"""
function protectMathBlocks(str::AbstractString)::Tuple{String,Dict{String,String}}
  placeholders = Dict{String,String}()
  tokenCounter = 0
  out = IOBuffer()
  i = firstindex(str)
  while i <= lastindex(str)
    if str[i] == '$'
      j = _findUnescapedDollar(str, nextind(str, i))
      if j !== nothing
        tokenCounter += 1
        token = "__BIBFMT_MATH_BLOCK_" * string(tokenCounter) * "__"
        placeholders[token] = str[i:j]
        print(out, token)
        i = nextind(str, j)
        continue
      end
    elseif startswith(SubString(str, i), raw"\(")
      afterOpen = nextind(str, nextind(str, i))
      closeRange = findnext(raw"\)", str, afterOpen)
      if closeRange !== nothing
        tokenCounter += 1
        token = "__BIBFMT_MATH_BLOCK_" * string(tokenCounter) * "__"
        placeholders[token] = str[i:last(closeRange)]
        print(out, token)
        i = nextind(str, last(closeRange))
        continue
      end
    end

    print(out, str[i])
    i = nextind(str, i)
  end
  String(take!(out)), placeholders
end

"""Restore placeholders produced by [`protectMathBlocks`](@ref)."""
function restoreMathBlocks(str::AbstractString, placeholders::Dict{String,String})::String
  out = String(str)
  for (token, block) in placeholders
    out = replace(out, token => block)
  end
  out
end

"""Decode common LaTeX special-character encodings to Unicode."""
function decodeLatexSpecialChars(str::AbstractString)::String
  out, placeholders = protectMathBlocks(str)
  for (pat, repl) in _latexSpecialReplacements
    out = replace(out, pat => repl)
  end
  restoreMathBlocks(out, placeholders)
end
