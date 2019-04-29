module PushVectors

export PushVector, finish!

mutable struct PushVector{T, V <: AbstractVector{T}} <: AbstractVector{T}
    "Vector used for storage."
    parent::V
    "Number of elements held by `parent`."
    len::Int
end

"""
    PushVector{T}(sizehint = 4)

Create a `PushVector` for elements typed `T`, with no initial elements. `sizehint`
determines the initial allocated size.
"""
function PushVector{T}(sizehint::Integer = 4) where {T}
    sizehint ≥ 0 || throw(DomainError(sizehint, "Invalid initial size."))
    PushVector(Vector{T}(undef, sizehint), 0)
end

Base.length(v::PushVector) = v.len

Base.size(v::PushVector) = (v.len, )

function Base.sizehint!(v::PushVector, n)
    if length(v.parent) < n || n ≥ v.len
        resize(v.parent, n)
    end
    nothing
end

@inline function Base.getindex(v::PushVector, i)
    @boundscheck checkbounds(v, i)
    @inbounds v.parent[i]
end

@inline function Base.setindex!(v::PushVector, x, i)
    @boundscheck checkbounds(v, i)
    @inbounds v.parent[i] = x
end

function Base.push!(v::PushVector, x)
    v.len += 1
    if v.len > length(v.parent)
        resize!(v.parent, v.len * 2)
    end
    v.parent[v.len] = x
    v
end

"""
    finish!(v)

Shrink the buffer `v` to its current content and return that vector.

!!! NOTE
    Consequences are undefined if you modify `v` after this.
"""
finish!(v::PushVector) = resize!(v.parent, v.len)

end # module
