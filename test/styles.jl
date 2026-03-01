using BibFormatter: styles
using Test

@testset "Styles, Latex output" begin
  for style in sort(collect(keys(styles)); by=string)
    @testset "$(style)" begin
      testStyleAgainstBbl(bibFile, style)
    end
  end
end
