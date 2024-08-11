struct OutputFormatHtml <: OutputFormat end

function outputAddPeriod(fmt::OutputFormatHtml, str::AbstractString)
  if !endswith(str, r"[.!?]\s*(</[a-zA-Z]+>)?")
    replace(str, r"\s*(</[a-zA-Z]+>)?$" => s"\1.")
  else
    str
  end
end

outputEmph(fmt::OutputFormatHtml, str::AbstractString) = "<em>$str</em>"
outputSmallCaps(fmt::OutputFormatHtml, str::AbstractString) = "<span class=\"sc\">$str</span>"
outputQuote(fmt::OutputFormatHtml, str::AbstractString) = "&ldquo;$str&rdquo;"
outputJoinSpace(fmt::OutputFormatHtml, list::AbstractVector{S}) where S = join(list, "&nbsp;")
outputNumberRange(fmt::OutputFormatHtml, pair::AbstractVector{S}) where S = join(pair, "&ndash;")
outputBlocks(fmt::OutputFormatHtml, blocks::AbstractVector{S}) where S = join(blocks, "\n")
