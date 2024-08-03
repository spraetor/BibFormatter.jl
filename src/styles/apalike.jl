struct Apalike <: BibliographyStyle end

formatAuthor(fmt::OutputFormat, style::Apalike, von, last, junior, first, second)::String = formatAuthorLastF(fmt, von, last, junior, first, second)

function formatArticle(style::Apalike, authors, title, journal, year; volume="", number="", pages="", month="", note="")
  vnp = formatVolumeNumberPagesCompact(volume,number,pages)
  return "$authors ($year). $title. $journal, $vnp."
end

function formatBook(style::Apalike, authors, editors, title, publisher, year; volume="", number="", series="", address="", edition="", month="", note="")
  _series=joinNotEmpty(" ",series,".")
  return "$authors. ($year). $title.$_series $publisher."
end