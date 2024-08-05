outputAddPeriod(fmt::OutputFormat, str::AbstractString) = endswith(str, ".") ? str : str * "."
outputEmph(fmt::OutputFormat, str::AbstractString) = str
outputSmallCaps(fmt::OutputFormat, str::AbstractString) = str
outputQuote(fmt::OutputFormat, str::AbstractString) = "\"$str\""
outputJoinSpace(fmt::OutputFormat, list::AbstractVector{S}) where S = join(list, " ")
outputNumberRange(fmt::OutputFormat, pair::AbstractVector{S}) where S = join(pair, "-")
outputBlocks(fmt::OutputFormat, blocks::Nothing) = "Not implemented"
outputBlocks(fmt::OutputFormat, blocks::AbstractVector{S}) where S = join(blocks, " ")