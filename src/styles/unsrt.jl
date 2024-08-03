struct Unsrt <: BibliographyStyle end

formatAuthor(fmt::OutputFormat, style::Unsrt, von, last, junior, first, second)::String = formatAuthorFirstLast(fmt, von, last, junior, first, second)

function formatArticle(style::Unsrt, authors, title, journal, year; volume="", number="", pages="", month="", note="")
  vnp = formatVolumeNumberPagesCompact(volume,number,pages)
  return "$authors. $title. $journal, $vnp, $year."
end

function formatBook(style::Unsrt, authors, editors, title, publisher, year; volume="", number="", series="", address="", edition="", month="", note="")
  _series=joinNotEmpty(" ",series,".")
  return "$authors. $title.$_series $publisher, $year."
end