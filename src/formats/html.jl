struct OutputFormatHtml <: OutputFormat end

function outputAddPeriod(::OutputFormatHtml, str::AbstractString)
  if !endswith(str, r"[.!?]\s*(</[a-zA-Z]+>)?")
    replace(str, r"\s*(</[a-zA-Z]+>)?$" => s"\1.")
  else
    str
  end
end

outputEmph(::OutputFormatHtml, str::AbstractString) = "<em>$str</em>"
outputSmallCaps(::OutputFormatHtml, str::AbstractString) = "<span class=\"smallcaps\">$str</span>"
function encodeOutputSpecialChars(::OutputFormatHtml, str::AbstractString)
  replace(str,
    "ä" => "&auml;", "Ä" => "&Auml;",
    "á" => "&aacute;", "Á" => "&Aacute;",
    "à" => "&agrave;", "À" => "&Agrave;",
    "â" => "&acirc;", "Â" => "&Acirc;",
    "ã" => "&atilde;", "Ã" => "&Atilde;",
    "å" => "&aring;", "Å" => "&Aring;",
    "æ" => "&aelig;", "Æ" => "&AElig;",
    "ö" => "&ouml;", "Ö" => "&Ouml;",
    "ó" => "&oacute;", "Ó" => "&Oacute;",
    "ò" => "&ograve;", "Ò" => "&Ograve;",
    "ô" => "&ocirc;", "Ô" => "&Ocirc;",
    "õ" => "&otilde;", "Õ" => "&Otilde;",
    "ø" => "&oslash;", "Ø" => "&Oslash;",
    "œ" => "&oelig;", "Œ" => "&OElig;",
    "ü" => "&uuml;", "Ü" => "&Uuml;",
    "ú" => "&uacute;", "Ú" => "&Uacute;",
    "ù" => "&ugrave;", "Ù" => "&Ugrave;",
    "û" => "&ucirc;", "Û" => "&Ucirc;",
    "ë" => "&euml;", "Ë" => "&Euml;",
    "é" => "&eacute;", "É" => "&Eacute;",
    "è" => "&egrave;", "È" => "&Egrave;",
    "ê" => "&ecirc;", "Ê" => "&Ecirc;",
    "ï" => "&iuml;", "Ï" => "&Iuml;",
    "í" => "&iacute;", "Í" => "&Iacute;",
    "ì" => "&igrave;", "Ì" => "&Igrave;",
    "î" => "&icirc;", "Î" => "&Icirc;",
    "ñ" => "&ntilde;", "Ñ" => "&Ntilde;",
    "ń" => "&#324;", "Ń" => "&#323;",
    "ś" => "&#347;", "Ś" => "&#346;",
    "ç" => "&ccedil;", "Ç" => "&Ccedil;",
    "ł" => "&#322;", "Ł" => "&#321;",
    "ý" => "&yacute;", "Ý" => "&Yacute;",
    "ÿ" => "&yuml;", "Ÿ" => "&#376;",
    "ß" => "&szlig;",
    "&" => "&amp;",
  )
end
outputLink(::OutputFormatHtml, href::AbstractString, text::AbstractString) = "<a href=\"$href\">$text</a>"
outputQuote(::OutputFormatHtml, str::AbstractString) = "&ldquo;$str&rdquo;"
outputJoinSpace(::OutputFormatHtml, list::AbstractVector) = join(list, "&nbsp;")
outputNumberRange(::OutputFormatHtml, pair::AbstractVector) = join(pair, "&ndash;")
outputBlocks(::OutputFormatHtml, blocks::AbstractVector) = join(blocks, "\n")
