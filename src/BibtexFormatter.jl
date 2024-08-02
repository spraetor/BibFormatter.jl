module BibtexFormatter

export bibliographyStyles
export format

import BibInternal
using EnumX

@enumx BibliographyStyles begin
  abbrv     # P. Rabinowitz, J. Kautsky, S. Elhay, and J. C. Butcher. Cubature formulas of degree nine for
            # symmetric planar regions. \emph{Mathematics of Computation}, 29(131):810-815,
            # 1975.

  acm       # \textsc{Rabinowitz, P., Kautsky, J., Elhay, S., and Butcher, J. C.} Cubature formulas of degree nine
            # for symmetric planar regions. \emph{Mathematics of Computation 29}, 131 (1975),
            # 810-815.

  alpha     # P. Rabinowitz, J. Kautsky, S. Elhay, and J. C. Butcher. Cubature formulas of degree
            # nine for symmetric planar regions. \emph{Mathematics of Computation},
            # 29(131):810-815, 1975.

  apalike   # Rabinowitz, P., Kautsky, J., Elhay, S., and Butcher, J. C. (1975). Cubature formulas of degree
            # nine for symmetric planar regions. \emph{Mathematics of Computation},
            # 29(131):810-815.

  ieeetr    # P. Rabinowitz, J. Kautsky, S. Elhay, and J. C. Butcher, ``Cubature formulas of degree nine for
            # symmetric planar regions,'' \emph{Mathematics of Computation}, vol. 29, no. 131,
            # pp. 810-815, 1975.

  plain     # P. Rabinowitz, J. Kautsky, S. Elhay, and J. C. Butcher. Cubature formulas of degree nine for
            # symmetric planar regions. \emph{Mathematics of Computation}, 29(131):810-815,
            # 1975.

  siam      # \textsc{P. Rabinowitz, J. Kautsky, S. Elhay, and J. C. Butcher}, \emph{Cubature formulas of degree nine
            # for symmetric planar regions}, Mathematics of Computation, 29 (1975),
            # pp. 810-815.

  unsrt     # P. Rabinowitz, J. Kautsky, S. Elhay, and J. C. Butcher. Cubature formulas of degree nine for
            # symmetric planar regions. \emph{Mathematics of Computation}, 29(131):810-815,
            # 1975.
end

abstract type BibliographyStyle end


# include the implementation of several formats
include("styles/abbrv.jl")
include("styles/acm.jl")
include("styles/alpha.jl")
include("styles/apalike.jl")
include("styles/ieeetr.jl")
include("styles/plain.jl")
include("styles/siam.jl")
include("styles/unsrt.jl")


# convert an enum of bibliography styles into the style type
function BibliographyStyle(style::BibliographyStyles.T)
  if style == BibliographyStyles.abbrv
    return Abbrv()
  elseif style == BibliographyStyles.acm 
    return Acm()
  elseif style == BibliographyStyles.alpha 
    return Alpha()
  elseif style == BibliographyStyles.apalike 
    return Apalike()
  elseif style == BibliographyStyles.ieeetr
    return Ieeetr()
  elseif style == BibliographyStyles.plain
    return Plain()
  elseif style == BibliographyStyles.siam
    return Siam()
  elseif style == BibliographyStyles.unsrt
    return Unsrt()
  else
    throw(ArgumentError("Unknown bibtex style '$style'"))
  end
end


# convert an string of bibliography styles into the style type
function BibliographyStyle(style::AbstractString)
  if style == "abbrv"
    return Abbrv()
  elseif style == "acm"
    return Acm()
  elseif style == "alpha"
    return Alpha()
  elseif style == "apalike"
    return Apalike()
  elseif style == "ieeetr"
    return Ieeetr()
  elseif style == "plain"
    return Plain()
  elseif style == "siam"
    return Siam()
  elseif style == "unsrt"
    return Unsrt()
  else
    throw(ArgumentError("Unknown bibtex style '$style'"))
  end
end


# some utilities and default formatting
include("utility.jl")
include("format.jl")
export format

"Format a bibtext entry into a string using the given bibtext style"
format(data::BibInternal.Entry, style::BibliographyStyles.T)::String = _format(BibliographyStyle(style), data)

"Format a bibtext entry into a string using the given bibtext style"
format(data::BibInternal.Entry, style::AbstractString="plain")::String = _format(BibliographyStyle(style), data)

end # module BibtexFormatter
