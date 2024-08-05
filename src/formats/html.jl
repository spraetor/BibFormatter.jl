struct OutputFormatHtml <: OutputFormat end

function outputAddPeriod(fmt::OutputFormatHtml, str::AbstractString)
  endswith(str, ".") || endswith(str, r"\.</[a-zA-Z]+>") ? str : str * "."
end

outputEmph(fmt::OutputFormatHtml, str::AbstractString) = "<em>$str</em>"
outputSmallCaps(fmt::OutputFormatHtml, str::AbstractString) = "<span class=\"sc\">$str</span>"
outputQuote(fmt::OutputFormatHtml, str::AbstractString) = "&ldquo;$str&rdquo;"
outputJoinSpace(fmt::OutputFormatHtml, list::AbstractVector{S}) where S = join(list, "&nbsp;")
outputNumberRange(fmt::OutputFormatHtml, pair::AbstractVector{S}) where S = join(pair, "&ndash;")
outputBlocks(fmt::OutputFormatHtml, blocks::AbstractVector{S}) where S = join(blocks, "\n")
