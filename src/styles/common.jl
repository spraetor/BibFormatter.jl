
module BibliographyStyleCommon

using ...BibFormatter: OutputFormat, outputEmph, outputSmallCaps, outputNumberRange, outputJoinSpace, formatAuthorFLast
import BibInternal

empty(str::AbstractString) = isempty(str)
empty(arr::AbstractVector{T}) where T = length(arr) == 0
empty(data::BibInternal.Entry, key::Symbol) = !hasproperty(data,key) || empty(getproperty(data,key)::String)
empty(data::Dict{String,String}, key::String) = empty(get(data,key,""))

emphasize(fmt::OutputFormat, str::AbstractString) = empty(str) ? "" : outputEmph(fmt, str)
scapify(fmt::OutputFormat, str::AbstractString) = empty(str) ? "" : outputSmallCaps(fmt, str)
dashify(fmt::OutputFormat, str::AbstractString) = empty(str) ? "" : outputNumberRange(fmt,split(str,'-'))

tieConnect(fmt::OutputFormat, arr::AbstractVector{T}) where T = outputJoinSpace(fmt,arr)
tieOrSpaceConnect(fmt::OutputFormat, arr::AbstractVector{T}) where T = length(arr[end]) < 3 ? tieConnect(fmt,arr) : join(arr," ")


const monthAbbrv = Dict(
  "jan" => "Jan.",
  "feb" => "Feb.",
  "mar" => "Mar.",
  "apr" => "Apr.",
  "may" => "May",
  "jun" => "June",
  "jul" => "July",
  "aug" => "Aug.",
  "sep" => "Sept.",
  "oct" => "Oct.",
  "nov" => "Nov.",
  "dec" => "Dec.",
)

replaceMonth(str::String) = empty(str) ? "" : get(monthAbbrv, str, str)

function formatNamesFLast(fmt::OutputFormat, names::BibInternal.Names)::String
  out = ""
  numnames = length(names)
  for (i,n) in enumerate(names)
    t = formatAuthorFLast(fmt, n.particle,n.last,n.junior,n.first,n.middle) # {f.~}{vv~}{ll}{, jj}
    if i > 1
      if numnames-i > 0     # namesleft > 1
        out *= ", " * t
      else
        if numnames > 2
          out *= ","
          if t == "others"
            out *= " " * tieConnect(fmt, ["et","al."]) # et~al.
          else
            out *= " and " * t
          end
        end
      end
    else
      out = t
    end
  end
  out
end

end # module BibliographyStyleCommon
