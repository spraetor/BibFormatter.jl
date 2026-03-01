struct OutputFormatText <: OutputFormat end

function outputAddPeriod(::OutputFormatText, str::AbstractString)
  endswith(str, r"[.!?]") ? str : str * "."
end

outputLink(::OutputFormatText, href::AbstractString, text::AbstractString) = text
outputQuote(::OutputFormatText, str::AbstractString) = "\"$str\""
outputJoinSpace(::OutputFormatText, list::AbstractVector) = join(list, " ")
outputNumberRange(::OutputFormatText, pair::AbstractVector) = join(pair, "-")