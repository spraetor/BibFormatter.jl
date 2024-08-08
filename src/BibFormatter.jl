module BibFormatter

export format

import BibInternal

abstract type BibliographyStyle end
abstract type OutputFormat end

# some utilities and default formatting
include("utility.jl")
include("output.jl")
include("format.jl")


# include the implementation of several bibtex styles
include("styles/common.jl")
include("styles/abbrv.jl")
include("styles/acm.jl")
include("styles/alpha.jl")
include("styles/apalike.jl")
include("styles/ieeetr.jl")
include("styles/plain.jl")
include("styles/siam.jl")
include("styles/unsrt.jl")


const styles = Dict(
  :abbrv => Abbrv(),
      # P. Rabinowitz, J. Kautsky, S. Elhay, and J. C. Butcher. Cubature formulas of degree nine for
      # symmetric planar regions. \emph{Mathematics of Computation}, 29(131):810-815,
      # 1975.

  :acm => Acm(),
      # \textsc{Rabinowitz, P., Kautsky, J., Elhay, S., and Butcher, J. C.} Cubature formulas of degree nine
      # for symmetric planar regions. \emph{Mathematics of Computation 29}, 131 (1975),
      # 810-815.

  :alpha => Alpha(),
      # P. Rabinowitz, J. Kautsky, S. Elhay, and J. C. Butcher. Cubature formulas of degree
      # nine for symmetric planar regions. \emph{Mathematics of Computation},
      # 29(131):810-815, 1975.

  :apalike => Apalike(),
      # Rabinowitz, P., Kautsky, J., Elhay, S., and Butcher, J. C. (1975). Cubature formulas of degree
      # nine for symmetric planar regions. \emph{Mathematics of Computation},
      # 29(131):810-815.

  :ieeetr => Ieeetr(),
      # P. Rabinowitz, J. Kautsky, S. Elhay, and J. C. Butcher, ``Cubature formulas of degree nine for
      # symmetric planar regions,'' \emph{Mathematics of Computation}, vol. 29, no. 131,
      # pp. 810-815, 1975.

  :plain => Plain(),
      # P. Rabinowitz, J. Kautsky, S. Elhay, and J. C. Butcher. Cubature formulas of degree nine for
      # symmetric planar regions. \emph{Mathematics of Computation}, 29(131):810-815,
      # 1975.

  :siam => Siam(),
      # \textsc{P. Rabinowitz, J. Kautsky, S. Elhay, and J. C. Butcher}, \emph{Cubature formulas of degree nine
      # for symmetric planar regions}, Mathematics of Computation, 29 (1975),
      # pp. 810-815.

  :unsrt => Unsrt(),
      # P. Rabinowitz, J. Kautsky, S. Elhay, and J. C. Butcher. Cubature formulas of degree nine for
      # symmetric planar regions. \emph{Mathematics of Computation}, 29(131):810-815,
      # 1975.
)

# convert an symbol of bibliography styles into the style type
function BibliographyStyle(style::Symbol)
  return styles[style]
end


# include the implementation of several output formats
include("formats/text.jl")
include("formats/html.jl")
include("formats/latex.jl")

const formats = Dict(
  :text => OutputFormatText(),
  :html => OutputFormatHtml(),
  :latex => OutputFormatLatex(),
)

# convert an symbol of output formats into the format type
function OutputFormat(fmt::Symbol)
  return formats[fmt]
end


"Format a bibtext entry into a string using the given bibtext style"
function format(data::BibInternal.Entry, style::Symbol = :abbrv, fmt::Symbol = :text)::String
  _format(OutputFormat(fmt), BibliographyStyle(style), data)
end

end # module BibFormatter
