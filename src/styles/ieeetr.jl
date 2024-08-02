struct Ieeetr <: BibliographyStyle end

formatAuthor(style::Ieeetr, von, last, junior, first, second)::String = formatAuthorFirstLast(von, last, junior, first, second)
authorDelimStyle(style::Ieeetr) = ","

function formatArticle(style::Ieeetr, authors, title, journal, year; volume="", number="", pages="", month="", note="")
  vnp = formatVolumeNumberPagesNamed(volume,number,pages)
  return "$authors, ``$title,'' $journal, $vnp, $year."
end

function formatBook(style::Ieeetr, authors, editors, title, publisher, year; volume="", number="", series="", address="", edition="", month="", note="")
  _series=joinNotEmpty(" ",series,",")
  return "$authors, $title.$_series $publisher, $year."
end