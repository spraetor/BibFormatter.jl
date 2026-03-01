using BibFormatter: styles
using Test
import Base.Filesystem

@testset "Styles, Latex output" begin
  for style in sort(collect(keys(styles)); by=string)
    @testset "$(style)" begin
      bblPath = Filesystem.joinpath(@__DIR__, "bbl", string(style) * ".bbl")
      testStyleAgainstBbl(bibFile, style, bblPath)
    end
  end
end
