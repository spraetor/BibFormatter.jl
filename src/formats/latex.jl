struct OutputFormatLatex <: OutputFormat end

function outputAddPeriod(::OutputFormatLatex, str::AbstractString)
  if !endswith(str, r"[.!?]\s*}?")
    replace(str, r"\s*(})?$" => s"\1.")
  else
    str
  end
end

outputEmph(::OutputFormatLatex, str::AbstractString) = "{\\em $str}"
outputEmphIc(fmt::OutputFormatLatex, str::AbstractString) = outputEmph(fmt, str * "\\/")
outputSmallCaps(::OutputFormatLatex, str::AbstractString) = "{\\sc $str}"
outputQuote(::OutputFormatLatex, str::AbstractString) = "``$str''"
outputJoinSpace(::OutputFormatLatex, list::AbstractVector) = join(list, "~")
outputNumberRange(::OutputFormatLatex, pair::AbstractVector) = join(pair, "--")
outputBlocks(::OutputFormatLatex, blocks::AbstractVector) = join(blocks, "\n\\newblock ")
