struct OutputFormatText <: OutputFormat end

function outputAddPeriod(::OutputFormatText, str::AbstractString)
  endswith(str, r"[.!?]") ? str : str * "."
end
encodeOutputSpecialChars(::OutputFormatText, str::AbstractString) = replace(str, "__AND__" => "&")
outputLink(::OutputFormatText, href::AbstractString, text::AbstractString) = text
outputQuote(::OutputFormatText, str::AbstractString) = "\"$str\""
outputJoinSpace(::OutputFormatText, list::AbstractVector) = join(list, " ")
outputNumberRange(::OutputFormatText, pair::AbstractVector) = join(pair, "-")