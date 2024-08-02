struct Unsrt <: BibliographyStyle end

formatAuthor(style::Unsrt, first, middle, last)::String = formatAuthorFirstLast(first,middle,last)
authorDelimStyle(style::Unsrt) = ","

function formatArticle(style::Unsrt, authors, title, journal, year; volume="", number="", pages="", month="", note="") 
  vnp = formatVolumeNumberPagesCompact(volume,number,pages)
  return "$authors. $title. $journal, $vnp, $year."
end

function formatBook(style::Unsrt, authors, editors, title, publisher, year; volume="", number="", series="", address="", edition="", month="", note="")
  _series=joinNotEmpty(" ",series,".")
  return "$authors. $title.$_series $publisher, $year."
end