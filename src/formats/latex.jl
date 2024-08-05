struct OutputFormatLatex <: OutputFormat end

outputAddPeriod(fmt::OutputFormatLatex, str::AbstractString) = endswith(str, ".") || endswith(str,".}") ? str : str * "."
outputEmph(fmt::OutputFormatLatex, str::AbstractString) = "{\\em $str}"
outputSmallCaps(fmt::OutputFormatLatex, str::AbstractString) = "{\\sc $str}"
outputQuote(fmt::OutputFormatLatex, str::AbstractString) = "``$str''"
outputJoinSpace(fmt::OutputFormatLatex, list::AbstractVector{S}) where S = join(list, "~")
outputNumberRange(fmt::OutputFormatLatex, pair::AbstractVector{S}) where S = join(pair, "--")
outputBlocks(fmt::OutputFormatLatex, blocks::AbstractVector{S}) where S = join(blocks, "\n\\newblock ")
