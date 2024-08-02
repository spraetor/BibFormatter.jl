struct Alpha <: BibliographyStyle end

formatAuthor(style::Alpha, first, middle, last)::String = formatAuthorFirstLast(first,middle,last)
authorDelimStyle(style::Alpha) = ","

function formatArticle(style::Alpha, authors, title, journal, year; volume="", number="", pages="", month="", note="") 
  vnp = formatVolumeNumberPagesCompact(volume,number,pages)
  return "$authors. $title. $journal, $vnp, $year."
end

function formatBook(style::Alpha, authors, editors, title, publisher, year; volume="", number="", series="", address="", edition="", month="", note="")
  _series=joinNotEmpty(" ",series,".")
  return "$authors. $title.$_series $publisher, $year."
end