using Logging
import BibInternal

formatBlock(fmt::OutputFormat, block::AbstractString) = outputAddPeriod(fmt, uppercasefirst(strip(block)))
formatBlocks(fmt::OutputFormat, style::BibliographyStyle, blocks::Nothing) = "Not implemented"
formatBlocks(fmt::OutputFormat, ::BibliographyStyle, blocks::AbstractVector) = outputBlocks(fmt, map((b) -> formatBlock(fmt,b), blocks))


# default implementation of all bibtex entry types
formatArticle(::OutputFormat, ::BibliographyStyle, ::BibInternal.Entry) = nothing
formatBook(::OutputFormat, ::BibliographyStyle, ::BibInternal.Entry) = nothing
formatBooklet(::OutputFormat, ::BibliographyStyle, ::BibInternal.Entry) = nothing
#formatConference(::OutputFormat, ::BibliographyStyle, daa::BibInternal.Entry) = nothing
formatInBook(::OutputFormat, ::BibliographyStyle, ::BibInternal.Entry) = nothing
formatInCollection(::OutputFormat, ::BibliographyStyle, ::BibInternal.Entry) = nothing
#formatInProceedings(::OutputFormat, ::BibliographyStyle, ::BibInternal.Entry) = nothing
formatManual(::OutputFormat, ::BibliographyStyle, ::BibInternal.Entry) = nothing
formatMastersThesis(::OutputFormat, ::BibliographyStyle, ::BibInternal.Entry) = nothing
formatMisc(::OutputFormat, ::BibliographyStyle, ::BibInternal.Entry) = nothing
formatPhDThesis(::OutputFormat, ::BibliographyStyle, ::BibInternal.Entry) = nothing
formatProceedings(::OutputFormat, ::BibliographyStyle, ::BibInternal.Entry) = nothing
formatTechreport(::OutputFormat, ::BibliographyStyle, ::BibInternal.Entry) = nothing
formatUnpublished(::OutputFormat, ::BibliographyStyle, ::BibInternal.Entry) = nothing


function _format(fmt::OutputFormat, style::BibliographyStyle, data::BibInternal.Entry)::String
  blocks = if data.type == "article"
    formatArticle(fmt, style, data)
  elseif data.type == "book"
    formatBook(fmt, style, data)
  elseif data.type == "booklet"
    formatBooklet(fmt, style, data)
  elseif data.type == "inbook"
    formatInBook(fmt, style, data)
  elseif data.type == "incollection"
    formatInCollection(fmt, style, data)
  elseif data.type == "manual"
    formatManual(fmt, style, data)
  elseif data.type == "mastersthesis"
    formatMastersThesis(fmt, style, data)
  elseif data.type == "misc"
    formatMisc(fmt, style, data)
  elseif data.type == "phdthesis"
    formatPhDThesis(fmt, style, data)
  elseif data.type == "proceedings"
    formatProceedings(fmt, style, data)
  elseif data.type == "techreport"
    formatTechreport(fmt, style, data)
  elseif data.type == "unpublished"
    formatUnpublished(fmt, style, data)
  else
    @warn "bibliography type '$(data.type)' not yet implemented"
    nothing
  end

  formatBlocks(fmt, style, blocks)
end
