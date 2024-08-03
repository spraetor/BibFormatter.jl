struct Alpha <: BibliographyStyle end

formatAuthor(fmt::OutputFormat, style::Alpha, von, last, junior, first, second)::String = formatAuthorFirstLast(fmt, von, last, junior, first, second)

function formatArticle(style::Alpha, authors, title, journal, year; volume="", number="", pages="", month="", note="")
  vnp = formatVolumeNumberPagesCompact(volume,number,pages)
  return "$authors. $title. $journal, $vnp, $year."
end

function formatBook(style::Alpha, authors, editors, title, publisher, year; volume="", number="", series="", address="", edition="", month="", note="")
  _series=joinNotEmpty(" ",series,".")
  return "$authors. $title.$_series $publisher, $year."
end