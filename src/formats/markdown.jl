struct OutputFormatMarkdown <: OutputFormat end

function outputAddPeriod(::OutputFormatMarkdown, str::AbstractString)
  if !endswith(str, r"[.!?]\s*}?")
    replace(str, r"\s*(})?$" => s".\1")
  else
    str
  end
end

outputEmph(::OutputFormatMarkdown, str::AbstractString) = "*$str*"
outputSmallCaps(::OutputFormatMarkdown, str::AbstractString) = "^^$str^^"
outputQuote(::OutputFormatMarkdown, str::AbstractString) = "\"$str\""
outputJoinSpace(::OutputFormatMarkdown, list::AbstractVector) = join(list, " ")
outputNumberRange(::OutputFormatMarkdown, pair::AbstractVector) = join(pair, "&ndash;")
outputBlocks(::OutputFormatMarkdown, blocks::AbstractVector) = join(blocks, "\n")
