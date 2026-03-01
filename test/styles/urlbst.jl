module UrlbstStyleTest

using BibFormatter: format
using Test

function testArticle(style::Symbol, entry::AbstractString)
  @test occursin("von Last, Junior", entry)
  @test occursin(raw"\newblock URL: \href{https://example.org/articles/this-is-a-title}{https://example.org/articles/this-is-a-title} [cited 26 August 2009].", entry)
  @test occursin(raw"\newblock \href{http://arxiv.org/abs/1234.56789}{arXiv:1234.56789}.", entry)
  @test occursin(raw"\newblock \href{https://doi.org/10.1234/56.abc.123}{doi:10.1234/56.abc.123}.", entry)
  @test occursin(raw"\newblock \href{http://www.ncbi.nlm.nih.gov/pubmed/34567890}{PMID:34567890}.", entry)
end

function testWebpage(style::Symbol, entry::AbstractString)
  @test occursin("The world wide web consortium, [online].", entry)
  @test occursin(raw"\newblock URL: \href{http://www.w3.org}{http://www.w3.org} [cited 26 August 2009].", entry)
end

function testLibrary(entries::AbstractDict{String,E}) where E
  rendered = Dict{Symbol,String}()
  for style in (:plainurl, :alphaurl, :unsrturl)
    rendered[style] = format(entries["Article"], style=style, fmt=:latex)
    testArticle(style, rendered[style])
    testWebpage(style, format(entries["WebPage"], style=style, fmt=:latex))
  end

  @test rendered[:plainurl] == rendered[:alphaurl]
  @test rendered[:plainurl] == rendered[:unsrturl]
end

end # module UrlbstStyleTest

# -----------------------------------------------------------------

UrlbstStyleTest.testLibrary(bibFile)
