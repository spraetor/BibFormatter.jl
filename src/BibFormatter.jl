module BibFormatter

import BibInternal

abstract type BibliographyStyle end
abstract type OutputFormat end

# some utilities and default formatting
include("specialsymbol.jl")
include("utility.jl")
include("output.jl")
include("names.jl")
include("style_text.jl")
include("months.jl")
include("journals.jl")
include("urls.jl")
include("format.jl")

# include the implementation of several bibtex styles
include("styles/abbrv.jl")
include("styles/acm.jl")
include("styles/apalike.jl")
include("styles/ieeetr.jl")
include("styles/plain.jl")
include("styles/siam.jl")
include("styles/urlbst.jl")

# alpha.bst and unsrt.bst currently match plain.bst behavior in this package.
const Alpha = Plain
const Unsrt = Plain

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
  :abbrvurl => Urlbst(Abbrv()),
  :plainurl => Urlbst(Plain()),
  :alphaurl => Urlbst(Alpha()),
  :unsrturl => Urlbst(Unsrt()),
)

# convert an symbol of bibliography styles into the style type
function BibliographyStyle(style::Symbol)
  return styles[style]
end


# include the implementation of several output formats
include("formats/html.jl")
include("formats/latex.jl")
include("formats/markdown.jl")
include("formats/text.jl")

const formats = Dict(
  :html => OutputFormatHtml(),
  :latex => OutputFormatLatex(),
  :md => OutputFormatMarkdown(),
  :text => OutputFormatText(),
)

# convert an symbol of output formats into the format type
function OutputFormat(fmt::Symbol)
  return formats[fmt]
end

# helpers to render full bibliography/library outputs
include("printlibrary.jl")


"Format a bibtex entry into a string using the given bibtex style"
function format(data::BibInternal.Entry; style::Symbol = :abbrv, fmt::Symbol = :text)::String
  _format(OutputFormat(fmt), BibliographyStyle(style), data)
end

"Format a bibtex entry using an explicit bibliography style instance."
function format(data::BibInternal.Entry, style::BibliographyStyle; fmt::Symbol = :text)::String
  _format(OutputFormat(fmt), style, data)
end


export BibliographyStyle, OutputFormat, OutputFormatLatex, OutputFormatHtml, OutputFormatText
export format
export printLibrary

end # module BibFormatter
