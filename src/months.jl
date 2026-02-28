"""BibTeX-style abbreviated month names used by several bibliography styles."""
const monthAbbrv = Dict(
  "jan" => "Jan.",
  "feb" => "Feb.",
  "mar" => "Mar.",
  "apr" => "Apr.",
  "may" => "May",
  "jun" => "June",
  "jul" => "July",
  "aug" => "Aug.",
  "sep" => "Sept.",
  "oct" => "Oct.",
  "nov" => "Nov.",
  "dec" => "Dec.",
)

"""Full month names used by styles that print expanded dates."""
const monthName = Dict(
  "jan" => "January",
  "feb" => "February",
  "mar" => "March",
  "apr" => "April",
  "may" => "May",
  "jun" => "June",
  "jul" => "July",
  "aug" => "August",
  "sep" => "September",
  "oct" => "October",
  "nov" => "November",
  "dec" => "December",
)

"""Replace a month token with its abbreviated display form."""
replaceMonth(str::String) = empty(str) ? "" : get(monthAbbrv, str, str)
"""Replace a month token with its full display form."""
replaceMonthName(str::String) = empty(str) ? "" : get(monthName, str, str)
