struct OutputFormatLatex <: OutputFormat end

# Emphasize some field
emphFieldTitle(fmt::OutputFormatLatex, title::AbstractString) = "{\\em $title}"
emphFieldSeries(fmt::OutputFormatLatex, series::AbstractString) = "{\\em $series}"
emphFieldJournal(fmt::OutputFormatLatex, journal::AbstractString) = "{\\em $journal}"


outputQuote(fmt::OutputFormatLatex, str::AbstractString) = "``$str''"
outputJoinSpace(fmt::OutputFormatLatex, list::AbstractVector{S}) where S = join(list, "~")
outputNumberRange(fmt::OutputFormatLatex, pair::AbstractVector{S}) where {S<:AbstractString} = join(pair, "--")
outputBlocks(fmt::OutputFormatLatex, blocks::AbstractVector{S}) where S = join(blocks, "\n\\newblock ")

outputEntry(fmt::OutputFormatLatex, key::AbstractString, entry::AbstractString) = "\\bibitem{$key}\n$entry\n"