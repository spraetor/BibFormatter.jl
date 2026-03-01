struct OutputFormatLatex <: OutputFormat end

function outputAddPeriod(::OutputFormatLatex, str::AbstractString)
  if !endswith(str, r"[.!?]\s*}?")
    replace(str, r"\s*(})?$" => s"\1.")
  else
    str
  end
end

outputEmph(::OutputFormatLatex, str::AbstractString) = "{\\em $str}"
outputEmphIc(fmt::OutputFormatLatex, str::AbstractString) = outputEmph(fmt, str * "\\/")
outputSmallCaps(::OutputFormatLatex, str::AbstractString) = "{\\sc $str}"
outputTitleCase(::OutputFormatLatex, str::AbstractString) = str
preprocessInputSpecialChars(::OutputFormatLatex, str::AbstractString) = decodeLatexSpecialChars(str)
function encodeOutputSpecialChars(::OutputFormatLatex, str::AbstractString)
  replace(str,
    "ä" => raw"{\\\"a}", "Ä" => raw"{\\\"A}",
    "á" => raw"{\'a}", "Á" => raw"{\'A}",
    "à" => raw"{\`a}", "À" => raw"{\`A}",
    "â" => raw"{\^a}", "Â" => raw"{\^A}",
    "ã" => raw"{\~a}", "Ã" => raw"{\~A}",
    "å" => raw"{\aa}", "Å" => raw"{\AA}",
    "æ" => raw"{\ae}", "Æ" => raw"{\AE}",
    "ö" => raw"{\\\"o}", "Ö" => raw"{\\\"O}",
    "ó" => raw"{\'o}", "Ó" => raw"{\'O}",
    "ò" => raw"{\`o}", "Ò" => raw"{\`O}",
    "ô" => raw"{\^o}", "Ô" => raw"{\^O}",
    "õ" => raw"{\~o}", "Õ" => raw"{\~O}",
    "ø" => raw"{\o}",  "Ø" => raw"{\O}",
    "œ" => raw"{\oe}", "Œ" => raw"{\OE}",
    "ü" => raw"{\\\"u}", "Ü" => raw"{\\\"U}",
    "ú" => raw"{\'u}", "Ú" => raw"{\'U}",
    "ù" => raw"{\`u}", "Ù" => raw"{\`U}",
    "û" => raw"{\^u}", "Û" => raw"{\^U}",
    "ë" => raw"{\\\"e}", "Ë" => raw"{\\\"E}",
    "é" => raw"{\'e}", "É" => raw"{\'E}",
    "è" => raw"{\`e}", "È" => raw"{\`E}",
    "ê" => raw"{\^e}", "Ê" => raw"{\^E}",
    "ï" => raw"{\\\"i}", "Ï" => raw"{\\\"I}",
    "í" => raw"{\'i}", "Í" => raw"{\'I}",
    "ì" => raw"{\`i}", "Ì" => raw"{\`I}",
    "î" => raw"{\^i}", "Î" => raw"{\^I}",
    "ñ" => raw"{\~n}", "Ñ" => raw"{\~N}",
    "ń" => raw"{\'n}", "Ń" => raw"{\'N}",
    "ś" => raw"{\'s}", "Ś" => raw"{\'S}",
    "ç" => raw"{\c{c}}", "Ç" => raw"{\c{C}}",
    "ł" => raw"{\l}",  "Ł" => raw"{\L}",
    "ý" => raw"{\'y}", "Ý" => raw"{\'Y}",
    "ÿ" => raw"{\\\"y}", "Ÿ" => raw"{\\\"Y}",
    "ß" => raw"{\ss}",
    "__AND__" => raw"\&",
  )
end
outputLink(::OutputFormatLatex, href::AbstractString, text::AbstractString) = href == text ? "\\url{$href}" : "\\href{$href}{$text}"
outputQuote(::OutputFormatLatex, str::AbstractString) = "``$str''"
outputJoinSpace(::OutputFormatLatex, list::AbstractVector) = join(list, "~")
outputNumberRange(::OutputFormatLatex, pair::AbstractVector) = join(pair, "--")
outputBlocks(::OutputFormatLatex, blocks::AbstractVector) = join(blocks, "\n\\newblock ")
