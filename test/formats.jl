using BibFormatter: format
using Test

@testset "Latex output" begin
  entry = bibFile["Article"]
  expected = raw"""
J.~{\ss}. von M{\\\"u}ller, Junior, F.~Wei{\ss}, and M.-K. O'Neil.
\newblock This is a {Title} with {API} and {BibTeX} case.
\newblock {\em Journal}, v123(b234):1--2, mm yyyy.
\newblock This is a note.
\newblock URL: \url{https://example.org/articles/this-is-a-title} [cited 26 August 2009].
\newblock \href{http://arxiv.org/abs/1234.56789}{arXiv:1234.56789}.
\newblock \href{https://doi.org/10.1234/56.abc.123}{doi:10.1234/56.abc.123}.
\newblock \href{http://www.ncbi.nlm.nih.gov/pubmed/34567890}{PMID:34567890}.
"""
  actual = format(entry, style=:abbrvurl, fmt=:latex)
  actual == "Not implemented" && return

  @test normalizeBibitem(expected) == normalizeBibitem(actual)
end

@testset "HTML output" begin
  entry = bibFile["Article"]
  expected = raw"""
J.&nbsp;&szlig;. von M&uuml;ller, Junior, F.&nbsp;Wei&szlig;, and M.-K. O'Neil.
This is a Title with API and BibTeX case.
<em>Journal</em>, v123(b234):1&ndash;2, mm yyyy.
This is a note.
URL: <a href="https://example.org/articles/this-is-a-title">https://example.org/articles/this-is-a-title</a> [cited 26 August 2009]. <a href="http://arxiv.org/abs/1234.56789">arXiv:1234.56789</a>. <a href="https://doi.org/10.1234/56.abc.123">doi:10.1234/56.abc.123</a>. <a href="http://www.ncbi.nlm.nih.gov/pubmed/34567890">PMID:34567890</a>.
"""
  actual = format(entry, style=:abbrvurl, fmt=:html)
  actual == "Not implemented" && return

  @test normalizeBibitem(expected) == normalizeBibitem(actual)
end


@testset "Text output" begin
  entry = bibFile["Article"]
  expected = raw"""
J. ß. von Müller, Junior, F. Weiß, and M.-K. O'Neil.
This is a Title with API and BibTeX case.
Journal, v123(b234):1-2, mm yyyy.
This is a note.
URL: https://example.org/articles/this-is-a-title [cited 26 August 2009]. ArXiv:1234.56789. Doi:10.1234/56.abc.123. PMID:34567890.
"""
  actual = format(entry, style=:abbrvurl, fmt=:text)
  actual == "Not implemented" && return

  @test normalizeBibitem(expected) == normalizeBibitem(actual)
end


@testset "Markdown output" begin
  entry = bibFile["Article"]
  expected = raw"""
J. ß. von Müller, Junior, F. Weiß, and M.-K. O'Neil.
This is a Title with API and BibTeX case.
*Journal*, v123(b234):1–2, mm yyyy.
This is a note.
URL: [https://example.org/articles/this-is-a-title](https://example.org/articles/this-is-a-title) [cited 26 August 2009]. [arXiv:1234.56789](http://arxiv.org/abs/1234.56789). [doi:10.1234/56.abc.123](https://doi.org/10.1234/56.abc.123). [PMID:34567890](http://www.ncbi.nlm.nih.gov/pubmed/34567890).
"""
  actual = format(entry, style=:abbrvurl, fmt=:md)
  actual == "Not implemented" && return

  @test normalizeBibitem(expected) == normalizeBibitem(actual)
end
