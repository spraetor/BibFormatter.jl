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
outputQuote(::OutputFormatHtml, str::AbstractString) = "&ldquo;$str&rdquo;"
outputJoinSpace(::OutputFormatHtml, list::AbstractVector) = join(list, "&nbsp;")
outputNumberRange(::OutputFormatHtml, pair::AbstractVector) = join(pair, "&ndash;")
outputBlocks(::OutputFormatHtml, blocks::AbstractVector) = join(blocks, "\n")
