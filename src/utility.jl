using Logging

pushNotEmpty!(a::AbstractArray{S,1}, s::AbstractString) where {S} = isempty(s) || push!(a,s)

joinNotEmpty(s1::AbstractString, s2::AbstractString) = (!isempty(s1) && !isempty(s2)) ? s1 * s2 : ""
joinNotEmpty(s1::AbstractString, s2::AbstractString, s...) = joinNotEmpty(joinNotEmpty(s1,s2),s...)

abbreviateName(str::AbstractString) = !isempty(str) ? str[1] * "." : ""

isMultiplePages(pages::AbstractString)::Bool = occursin("-", pages)
isMultipleAuthors(authors::AbstractString)::Bool = occursin(" and ", authors)

function checkRequiredField(type::AbstractString, field::AbstractString)
  if isempty(field)
    @warn "Missing required field '$field' for bibliography type '$type'"
  end
end

function checkRequiredField(type::AbstractString, field::AbstractArray{T,1}) where {T}
  if length(field) == 0
    @warn "Missing required field '$field' for bibliography type '$type'"
  end
end

function checkRequiredFields(type::AbstractString, fields...)
  for field in fields
    checkRequiredField(type,field)
  end
end