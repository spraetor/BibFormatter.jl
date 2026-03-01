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
preprocessInputSpecialChars(::OutputFormatLatex, str::AbstractString) = str
function encodeOutputSpecialChars(::OutputFormatLatex, str::AbstractString)
  replace(str,
    "ä" => "{\\\"a}", "Ä" => "{\\\"A}",
    "á" => "{\\'a}", "Á" => "{\\'A}",
    "à" => "{\\`a}", "À" => "{\\`A}",
    "â" => "{\\^a}", "Â" => "{\\^A}",
    "ã" => "{\\~a}", "Ã" => "{\\~A}",
    "å" => "{\\aa}", "Å" => "{\\AA}",
    "æ" => "{\\ae}", "Æ" => "{\\AE}",
    "ö" => "{\\\"o}", "Ö" => "{\\\"O}",
    "ó" => "{\\'o}", "Ó" => "{\\'O}",
    "ò" => "{\\`o}", "Ò" => "{\\`O}",
    "ô" => "{\\^o}", "Ô" => "{\\^O}",
    "õ" => "{\\~o}", "Õ" => "{\\~O}",
    "ø" => "{\\o}", "Ø" => "{\\O}",
    "œ" => "{\\oe}", "Œ" => "{\\OE}",
    "ü" => "{\\\"u}", "Ü" => "{\\\"U}",
    "ú" => "{\\'u}", "Ú" => "{\\'U}",
    "ù" => "{\\`u}", "Ù" => "{\\`U}",
    "û" => "{\\^u}", "Û" => "{\\^U}",
    "ë" => "{\\\"e}", "Ë" => "{\\\"E}",
    "é" => "{\\'e}", "É" => "{\\'E}",
    "è" => "{\\`e}", "È" => "{\\`E}",
    "ê" => "{\\^e}", "Ê" => "{\\^E}",
    "ï" => "{\\\"i}", "Ï" => "{\\\"I}",
    "í" => "{\\'i}", "Í" => "{\\'I}",
    "ì" => "{\\`i}", "Ì" => "{\\`I}",
    "î" => "{\\^i}", "Î" => "{\\^I}",
    "ñ" => "{\\~n}", "Ñ" => "{\\~N}",
    "ń" => "{\\'n}", "Ń" => "{\\'N}",
    "ç" => "{\\c{c}}", "Ç" => "{\\c{C}}",
    "ł" => "{\\l}", "Ł" => "{\\L}",
    "ý" => "{\\'y}", "Ý" => "{\\'Y}",
    "ÿ" => "{\\\"y}", "Ÿ" => "{\\\"Y}",
    "ß" => "{\\ss}",
  )
end
outputLink(::OutputFormatLatex, href::AbstractString, text::AbstractString) = "\\href{$href}{$text}"
outputQuote(::OutputFormatLatex, str::AbstractString) = "``$str''"
outputJoinSpace(::OutputFormatLatex, list::AbstractVector) = join(list, "~")
outputNumberRange(::OutputFormatLatex, pair::AbstractVector) = join(pair, "--")
outputBlocks(::OutputFormatLatex, blocks::AbstractVector) = join(blocks, "\n\\newblock ")
