struct Siam <: BibliographyStyle end

formatAuthor(style::Siam, first, middle, last)::String = formatAuthorFirstLast(first,middle,last)
authorDelimStyle(style::Siam) = ","

function formatArticle(style::Siam, authors, title, journal, year; volume="", number="", pages="", month="", note="") 
  vnp = formatVolumeNumberPagesCompact(volume,number,pages)
  return "$authors, $title, $journal, $volume ($year), pp. $pages."
end

function formatBook(style::Siam, authors, editors, title, publisher, year; volume="", number="", series="", address="", edition="", month="", note="")
  _series=joinNotEmpty(" ",series,",")
  return "$authors, $title,$_series $publisher, $year."
end