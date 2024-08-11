using BibFormatter: OutputFormat, OutputFormatLatex, OutputFormatHtml, OutputFormatText, outputAddPeriod

function testOutput(fmt::OutputFormatHtml)

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

function testOutput(fmt::OutputFormatText)

end


for fmt in (:text, :html, :latex)
  testOutput(OutputFormat(fmt))
end