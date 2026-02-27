using BibFormatter
using BibFormatter: outputAddPeriod

function testOutput(::OutputFormatHtml)

end

function testOutput(fmt::OutputFormatLatex)
  @test outputAddPeriod(fmt, "str") == "str."
  @test outputAddPeriod(fmt, "str.") == "str."
  @test outputAddPeriod(fmt, "str!") == "str!"
  @test outputAddPeriod(fmt, "str?") == "str?"

  @test outputAddPeriod(fmt, "\emph{str}") == "\emph{str}."
  @test outputAddPeriod(fmt, "\emph{str.}") == "\emph{str.}"
  @test outputAddPeriod(fmt, "\emph{str!}") == "\emph{str!}"
  @test outputAddPeriod(fmt, "\emph{str?}") == "\emph{str?}"
end

function testOutput(::OutputFormatText)

end


for fmt in (:text, :html, :latex)
  testOutput(OutputFormat(fmt))
end