struct Acm <: BibliographyStyle end

formatAuthor(style::Acm, first, middle, last)::String = formatAuthorLastFirst(first,middle,last)
authorDelimStyle(style::Acm) = ","

function formatArticle(style::Acm, authors, title, journal, year; volume="", number="", pages="", month="", note="") 
  vn = formatVolumeNumber(volume,number)
  return "$authors $title. $journal $vn ($year), $pages."
end

function formatBook(style::Acm, authors, editors, title, publisher, year; volume="", number="", series="", address="", edition="", month="", note="")
  _series=joinNotEmpty(" ",series,".")
  return "$authors. $title.$_series $publisher, $year."
end