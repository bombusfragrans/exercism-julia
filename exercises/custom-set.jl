abstract type AbstractCustomSet{T} <: AbstractSet{T} end

struct CustomSet{T} <: AbstractCustomSet{T}
    cset::Vector{T}
end

CustomSet(a::Array) = CustomSet{eltype(a)}(unique(a))

Base.iterate(cs::CustomSet) = iterate(cs.cset)

Base.iterate(cs::CustomSet, i::Integer) = iterate(cs.cset, i)

Base.length(cs::CustomSet) = length(cs.cset)

Base.push!(cs::CustomSet, i...) = CustomSet(union(cs.cset,i))

Base.union!(csx::CustomSet, csy::CustomSet) = CustomSet(union(csx.cset,csy.cset)) 

Base.copy(cs::CustomSet) = CustomSet(cs.cset)

#=
still needed
intersect! -> filter!
complement
complement!
=#
