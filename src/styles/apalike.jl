struct Apalike <: BibliographyStyle end

formatAuthor(style::Apalike, first, middle, last)::String = formatAuthorLastFirst(first,middle,last)
authorDelimStyle(style::Apalike) = ","

function formatArticle(style::Apalike, authors, title, journal, year; volume="", number="", pages="", month="", note="") 
  vnp = formatVolumeNumberPagesCompact(volume,number,pages)
  return "$authors ($year). $title. $journal, $vnp."
end

function formatBook(style::Apalike, authors, editors, title, publisher, year; volume="", number="", series="", address="", edition="", month="", note="")
  _series=joinNotEmpty(" ",series,".")
  return "$authors. ($year). $title.$_series $publisher."
end