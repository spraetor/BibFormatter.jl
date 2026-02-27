outputAddPeriod(::OutputFormat, str::AbstractString) = endswith(str, ".") ? str : str * "."
outputEmph(::OutputFormat, str::AbstractString) = str
outputSmallCaps(::OutputFormat, str::AbstractString) = str
outputQuote(::OutputFormat, str::AbstractString) = "\"$str\""
outputJoinSpace(::OutputFormat, list::AbstractVector) = join(list, " ")
outputNumberRange(::OutputFormat, pair::AbstractVector) = join(pair, "-")
outputBlocks(::OutputFormat, blocks::Nothing) = "Not implemented"
outputBlocks(::OutputFormat, blocks::AbstractVector) = join(blocks, " ")