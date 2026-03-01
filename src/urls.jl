"""URL-related literal strings used by urlbst-derived styles."""
Base.@kwdef struct UrlBstVariables
  urlintro::String = "URL: "
  onlinestring::String = "online"
  citedstring::String = "cited "
  linktextstring::String = "[link]"
  eprinturl::String = "http://arxiv.org/abs/"
  eprintprefix::String = "arXiv:"
  doiurl::String = "https://doi.org/"
  doiprefix::String = "doi:"
  pubmedurl::String = "http://www.ncbi.nlm.nih.gov/pubmed/"
  pubmedprefix::String = "PMID:"
end

"""Remove optional DOI resolver prefixes from a DOI field value."""
function stripDoiResolverPrefix(doi::AbstractString)::String
  strip(replace(doi, r"^https?://(dx\.)?doi\.org/"i => ""))
end

"""Return `true` when any URL-like reference field is set."""
function hasWebReferences(data::BibInternal.Entry)::Bool
  !empty(data.access.url) ||
  !empty(data.access.doi) ||
  !empty(data.eprint.eprint) ||
  !empty(get(data.fields, "pubmed", ""))
end

"""Format urlbst-style bracketed last-checked suffix."""
function formatLastChecked(vars::UrlBstVariables, data::BibInternal.Entry)::String
  lastchecked = get(data.fields, "lastchecked", "")
  empty(lastchecked) ? "" : " [" * vars.citedstring * lastchecked * "]"
end

"""Choose the best resolver URL for inline-link attachment."""
function inlineHref(
  vars::UrlBstVariables,
  data::BibInternal.Entry;
  addeprints::Bool = true,
  adddoiresolver::Bool = true,
  addpubmedresolver::Bool = true,
)::String
  if adddoiresolver && !empty(data.access.doi)
    return vars.doiurl * stripDoiResolverPrefix(data.access.doi)
  elseif addpubmedresolver && !empty(get(data.fields, "pubmed", ""))
    return vars.pubmedurl * get(data.fields, "pubmed", "")
  elseif addeprints && !empty(data.eprint.eprint)
    return vars.eprinturl * data.eprint.eprint
  else
    return data.access.url
  end
end

"""Attach an inline link to `text` when enabled, otherwise return `text` unchanged."""
function possiblySetupInlineLink(
  fmt::OutputFormat,
  text::AbstractString,
  vars::UrlBstVariables,
  data::BibInternal.Entry;
  inlinelinks::Bool = false,
  addeprints::Bool = true,
  adddoiresolver::Bool = true,
  addpubmedresolver::Bool = true,
)::String
  if !inlinelinks || empty(text)
    return text
  end
  href = inlineHref(vars, data;
    addeprints=addeprints,
    adddoiresolver=adddoiresolver,
    addpubmedresolver=addpubmedresolver,
  )
  empty(href) ? text : outputLink(fmt, href, text)
end

"""Format explicit URL field output (suppressed for inline-link mode)."""
function formatUrl(
  fmt::OutputFormat,
  vars::UrlBstVariables,
  data::BibInternal.Entry;
  inlinelinks::Bool = false,
)::String
  if inlinelinks || empty(data.access.url)
    return ""
  end
  vars.urlintro * outputLink(fmt, data.access.url, data.access.url)
end

"""Format explicit eprint resolver output."""
function formatEprint(
  fmt::OutputFormat,
  vars::UrlBstVariables,
  data::BibInternal.Entry;
  addeprints::Bool = true,
)::String
  if !addeprints || empty(data.eprint.eprint)
    return ""
  end
  outputLink(fmt, vars.eprinturl * data.eprint.eprint, vars.eprintprefix * data.eprint.eprint)
end

"""Format explicit DOI resolver output."""
function formatDoi(
  fmt::OutputFormat,
  vars::UrlBstVariables,
  data::BibInternal.Entry;
  adddoiresolver::Bool = true,
)::String
  if !adddoiresolver || empty(data.access.doi)
    return ""
  end
  doi = stripDoiResolverPrefix(data.access.doi)
  outputLink(fmt, vars.doiurl * doi, vars.doiprefix * doi)
end

"""Format explicit PubMed resolver output."""
function formatPubmed(
  fmt::OutputFormat,
  vars::UrlBstVariables,
  data::BibInternal.Entry;
  addpubmedresolver::Bool = true,
)::String
  pubmed = get(data.fields, "pubmed", "")
  if !addpubmedresolver || empty(pubmed)
    return ""
  end
  outputLink(fmt, vars.pubmedurl * pubmed, vars.pubmedprefix * pubmed)
end

"""Format all explicit urlbst web-reference blocks for an entry."""
function formatWebReferences(
  fmt::OutputFormat,
  vars::UrlBstVariables,
  data::BibInternal.Entry;
  inlinelinks::Bool = false,
  addeprints::Bool = true,
  adddoiresolver::Bool = true,
  addpubmedresolver::Bool = true,
)::Vector{String}
  blocks = String[]

  if !inlinelinks
    skipUrl = false
    if adddoiresolver && !empty(data.access.doi) && !empty(data.access.url)
      doi = stripDoiResolverPrefix(data.access.doi)
      skipUrl = (vars.doiurl * doi) == data.access.url
    end

    if !skipUrl
      urlblock = formatUrl(fmt, vars, data; inlinelinks=inlinelinks)
      !empty(urlblock) && push!(blocks, urlblock * formatLastChecked(vars, data))
    end
  end

  eprintBlock = formatEprint(fmt, vars, data; addeprints=addeprints)
  !empty(eprintBlock) && push!(blocks, eprintBlock)

  doiBlock = formatDoi(fmt, vars, data; adddoiresolver=adddoiresolver)
  !empty(doiBlock) && push!(blocks, doiBlock)

  pubmedBlock = formatPubmed(fmt, vars, data; addpubmedresolver=addpubmedresolver)
  !empty(pubmedBlock) && push!(blocks, pubmedBlock)

  blocks
end
