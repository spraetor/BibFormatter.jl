struct OutputFormatText <: OutputFormat end

function outputAddPeriod(::OutputFormatText, str::AbstractString)
  endswith(str, r"[.!?]") ? str : str * "."
end

outputQuote(::OutputFormatText, str::AbstractString) = "\"$str\""
outputJoinSpace(::OutputFormatText, list::AbstractVector) = join(list, " ")
outputNumberRange(::OutputFormatText, pair::AbstractVector) = join(pair, "-")