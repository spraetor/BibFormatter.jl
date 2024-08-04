struct OutputFormatLatex <: OutputFormat end

outputEmph(fmt::OutputFormatLatex, str::AbstractString) = "{\\em $str}"
outputSmallCaps(fmt::OutputFormatLatex, str::AbstractString) = "{\\sc $str}"
outputQuote(fmt::OutputFormatLatex, str::AbstractString) = "``$str''"
outputJoinSpace(fmt::OutputFormatLatex, list::AbstractVector{S}) where S = join(list, "~")
outputNumberRange(fmt::OutputFormatLatex, pair::AbstractVector{S}) where {S<:AbstractString} = join(pair, "--")
outputBlocks(fmt::OutputFormatLatex, blocks::AbstractVector{S}) where S = join(blocks, "\n\\newblock ")
