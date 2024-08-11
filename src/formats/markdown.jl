struct OutputFormatMarkdown <: OutputFormat end

function outputAddPeriod(fmt::OutputFormatMarkdown, str::AbstractString)
  if !endswith(str, r"[.!?]\s*}?")
    replace(str, r"\s*(})?$" => s".\1")
  else
    str
  end
end

outputEmph(fmt::OutputFormatMarkdown, str::AbstractString) = "*$str*"
outputSmallCaps(fmt::OutputFormatMarkdown, str::AbstractString) = "^^$str^^"
outputQuote(fmt::OutputFormatMarkdown, str::AbstractString) = "\"$str\""
outputJoinSpace(fmt::OutputFormatMarkdown, list::AbstractVector{S}) where S = join(list, " ")
outputNumberRange(fmt::OutputFormatMarkdown, pair::AbstractVector{S}) where S = join(pair, "&ndash;")
outputBlocks(fmt::OutputFormatMarkdown, blocks::AbstractVector{S}) where S = join(blocks, "\n")
