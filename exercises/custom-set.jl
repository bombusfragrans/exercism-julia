# not to merely copy AbstractSet.jl and Set.Jl from master and for comparison reasons
# the CustomSet is implemented on an mutable struct (due to required `!` methods) 
# containing `Vector` (and not `Dicts` as in Set.jl)

abstract type AbstractCustomSet{T} <: AbstractSet{T} end

mutable struct CustomSet{T} <: AbstractCustomSet{T}
    v::Vector{T}
    CustomSet(vv::Vector) = new{eltype(vv)}(unique(vv))
    CustomSet(m::Matrix) = new{eltype(m)}(unique(vec(m)))
    # internal constructor because otherwise outer constructor would be bypassed by default constructor
    # if e.g. `[1,1,2,2,3,3]` would be given which woud be of type `Vector`
end

Base.iterate(cs::CustomSet) = iterate(cs.v)

Base.iterate(cs::CustomSet, i::Integer) = iterate(cs.v, i) 

Base.length(cs::CustomSet) = length(cs.v)

#=
already works due to 'inheritance' from `AbstractSet`:
- `union`
- `isdisjoint`
- `issubset`
- `==`
- `intersect`
- `setdiff`
=#

Base.copy(cs::CustomSet) = CustomSet(cs.v)

# 'enables' also `union!`

Base.push!(cs::CustomSet, items...) = (cs.v = union!(cs.v, items...))

# 'enables' also `setdiff!` and `intersect!`

Base.delete!(cs::CustomSet, idx::Int) = deleteat!(cs.v, idx) 

Base.filter!(fct::Function, cs::CustomSet) = filter!(fct, cs.v)

# just an 'alias' of another method defined by AbstractSet

disjoint(csx::CustomSet, csy::CustomSet) = isdisjoint(csx, csy)

complement(cs::CustomSet, itrs...) = CustomSet(collect(setdiff(cs.v, itrs...)))

complement!(cs::CustomSet, itrs...) = (cs.v = setdiff!(cs.v, itrs...))

