struct OutputFormatHtml <: OutputFormat end

outputEmph(fmt::OutputFormatHtml, str::AbstractString) = "<em>$str</em>"
outputSmallCaps(fmt::OutputFormatHtml, str::AbstractString) = "<span class=\"sc\">$str</span>"
outputQuote(fmt::OutputFormatHtml, str::AbstractString) = "&ldquo;$str&rdquo;"
outputNumberRange(fmt::OutputFormatHtml, pair::AbstractVector{S}) where {S<:AbstractString} = join(pair, "&ndash;")
outputBlocks(fmt::OutputFormatHtml, blocks::AbstractVector{S}) where S = join(blocks, "\n")
