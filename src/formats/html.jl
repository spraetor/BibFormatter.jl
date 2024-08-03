struct OutputFormatHtml <: OutputFormat end

# Emphasize some field
emphFieldTitle(fmt::OutputFormatHtml, title::AbstractString) = "<em>$title</em>"
emphFieldSeries(fmt::OutputFormatHtml, series::AbstractString) = "<em>$series</em>"
emphFieldJournal(fmt::OutputFormatHtml, journal::AbstractString) = "<em>$journal</em>"

outputEmph(fmt::OutputFormatHtml, str::AbstractString) = "<em>$str</em>"
outputSmallCaps(fmt::OutputFormatHtml, str::AbstractString) = "<span class=\"sc\">$str</span>"
outputQuote(fmt::OutputFormatHtml, str::AbstractString) = "&ldquo;$str&rdquo;"
outputNumberRange(fmt::OutputFormatHtml, pair::AbstractVector{S}) where {S<:AbstractString} = join(pair, "&mdash;")
outputBlocks(fmt::OutputFormatHtml, blocks::AbstractVector{S}) where S = join(blocks, "\n")

outputEntry(fmt::OutputFormatHtml, key::AbstractString, entry::AbstractString) = "<div class=\"bibitem\" id=\"$key\">\n$entry\n</div>"