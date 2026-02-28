"""Apply output-format-specific emphasis and return empty string for empty input."""
emphasize(fmt::OutputFormat, str::AbstractString) = empty(str) ? "" : outputEmph(fmt, str)

"""
    emphasizeic(fmt, str)

Italic-correction variant of [`emphasize`](@ref). Delegates to
`outputEmphIc(fmt, str)` in the output layer.
"""
emphasizeic(fmt::OutputFormat, str::AbstractString) = empty(str) ? "" : outputEmphIc(fmt, str)

"""Apply output-format-specific small-caps styling and return empty string for empty input."""
scapify(fmt::OutputFormat, str::AbstractString) = empty(str) ? "" : outputSmallCaps(fmt, str)
"""Normalize numeric ranges using output-format-specific range separators."""
dashify(fmt::OutputFormat, str::AbstractString) = empty(str) ? "" : outputNumberRange(fmt, split(str, '-'))

"""Join tokens using output-format-specific non-breaking spacing."""
tieConnect(fmt::OutputFormat, arr::AbstractVector) = outputJoinSpace(fmt, arr)
"""Use tight (non-breaking) spacing for short trailing tokens, otherwise plain spacing."""
tieOrSpaceConnect(fmt::OutputFormat, arr::AbstractVector) = length(arr[end]) < 3 ? tieConnect(fmt, arr) : join(arr, " ")
