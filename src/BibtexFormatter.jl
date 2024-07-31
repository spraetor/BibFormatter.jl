module BibtexFormatter

export bibliographyStyles
export format

import BibInternal
using EnumX

@enumx BibliographyStyles begin
  abbrev    # P. Rabinowitz, J. Kautsky, S. Elhay, and J. C. Butcher. Cubature formulas of degree nine for
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


# abstract type AbstractBibliographyStyle end

# abstract type AbstractAuthorStyle end
# abstract type AbstractTitleStyle end
# abstract type AbstractJournalStyle end
# abstract type AbstractVolumeStyle end
# abstract type AbstractYearStyle end

# struct BibliographyStyle{ AuthorStyle<:AbstractAuthorStyle,
#                           TitleStyle<:AbstractTitleStyle,
#                           JournalStyle<:AbstractJournalStyle,
#                           VolumeStyle<:AbstractVolumeStyle,
#                           YearStyle<:AbstractYearStyle } <: AbstractBibliographyStyle
#   authorStyle::AuthorStyle
#   titleStyle::TitleStyle
#   journalStyle::JournalStyle
#   volumeStyle::VolumeStyle
#   yearStyle::YearStyle
# end

const bibliographyStyles = Dict(
  "abbrv" => BibliographyStyles.abbrev,
  "acm" => BibliographyStyles.acm,
  "alpha" => BibliographyStyles.alpha,
  "apalike" => BibliographyStyles.apalike,
  "ieeetr" => BibliographyStyles.ieeetr,
  "plain" => BibliographyStyles.plain,
  "siam" => BibliographyStyles.siam,
  "unsrt" => BibliographyStyles.unsrt
)

include("format.jl")
export format

"Format a bibtext entry into a string using the given bibtext style"
format(data::BibInternal.Entry, style::BibliographyStyles.T)::String = _format(data, style)

"Format a bibtext entry into a string using the given bibtext style"
format(data::BibInternal.Entry, style::AbstractString="plain")::String = _format(data, bibliographyStyles[style])

end # module BibtexFormatter
