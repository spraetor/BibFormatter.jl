struct OutputFormatText <: OutputFormat end

function outputAddPeriod(fmt::OutputFormatText, str::AbstractString)
  endswith(str, r"[.!?]") ? str : str * "."
end

outputQuote(fmt::OutputFormatText, str::AbstractString) = "\"$str\""
outputJoinSpace(fmt::OutputFormatText, list::AbstractVector{S}) where S = join(list, " ")
outputNumberRange(fmt::OutputFormatText, pair::AbstractVector{S}) where S = join(pair, "-")