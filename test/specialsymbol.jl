module SpecialSymbolTest

using Test
using BibFormatter: OutputFormat, decodeLatexSpecialChars, encodeOutputSpecialChars

const unicodeSymbols = [
  "ä", "Ä", "ö", "Ö", "ü", "Ü", "ë", "Ë", "ï", "Ï", "ÿ", "Ÿ",
  "á", "Á", "é", "É", "í", "Í", "ó", "Ó", "ú", "Ú", "ý", "Ý", "ń", "Ń",
  "à", "À", "è", "È", "ì", "Ì", "ò", "Ò", "ù", "Ù",
  "â", "Â", "ê", "Ê", "î", "Î", "ô", "Ô", "û", "Û",
  "ã", "Ã", "ñ", "Ñ", "õ", "Õ",
  "ç", "Ç", "ø", "Ø", "ł", "Ł", "æ", "Æ", "œ", "Œ", "å", "Å", "ß",
]

@testset "Special Symbol Conversion" begin
  latex = OutputFormat(:latex)
  html = OutputFormat(:html)
  md = OutputFormat(:md)
  text = OutputFormat(:text)

  for unicodeChar in unicodeSymbols
    latexInput = encodeOutputSpecialChars(latex, unicodeChar)
    decoded = decodeLatexSpecialChars(latexInput)
    @test decoded == unicodeChar

    # Canonical roundtrip for LaTeX output representation.
    @test encodeOutputSpecialChars(latex, decoded) == latexInput

    # Other outputs should accept the decoded Unicode and encode without LaTeX markup.
    htmlOut = encodeOutputSpecialChars(html, decoded)
    mdOut = encodeOutputSpecialChars(md, decoded)
    textOut = encodeOutputSpecialChars(text, decoded)

    @test !isempty(htmlOut)
    @test !isempty(mdOut)
    @test !isempty(textOut)

    @test !occursin("\\", htmlOut)
    @test !occursin("{", htmlOut)
    @test !occursin("}", htmlOut)

    @test mdOut == unicodeChar
    @test textOut == unicodeChar
  end
end

end # module SpecialSymbolTest
