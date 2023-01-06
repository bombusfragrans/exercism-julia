abstract type AbstractCustomSet{T} <: AbstractSet{T} end

mutable struct CustomSet{T} <: AbstractCustomSet{T}
    cset::Vector{T}
end

abstract type AbstractIterable{T} end

struct Iterable{T} <: AbstractIterable{T} end

function Iterable(itrs...)
    any(i -> length(methods(iterate,(typeof(i),))) == 0, itrs) ?
        Iterable{false} : Iterable{true}
end

CustomSet(a::Array) = CustomSet{eltype(a)}(unique(a))

Base.iterate(cs::CustomSet) = iterate(cs.cset)

Base.iterate(cs::CustomSet, i::Integer) = iterate(cs.cset, i)

Base.length(cs::CustomSet) = length(cs.cset)

Base.push!(cs::CustomSet, i...) = union!(cs.cset,i)

Base.union!(csx::CustomSet, csy::CustomSet) = union!(csx.cset,csy.cset) 

Base.union(csx::CustomSet, csy::CustomSet) = CustomSet(union(csx.cset,csy.cset))

Base.copy(cs::CustomSet) = CustomSet(cs.cset)

function _isiterable(cs::CustomSet, itrs::Tuple; fct::Function)
    _isiterable(Iterable(itrs...), cs, itrs; fct=fct)
end

_isiterable(::Iterable{false}, _, __) = error("At least one argument is not an iterable")

_isiterable(::Iterable{true}, cs, itrs; fct) = fct(cs, itrs...)

function Base.intersect(cs::CustomSet, itrs...)
    _isiterable(cs, itrs; fct=intersect)
end

#Base.intersect!(cs::CustomSet, itr...) # Test for Iterable: `length(methods(funct,(Type,)))`

#=
still needed
intersect (if x or y is empty return empty[])
complement (if x is empty return empty[], if x not empty but y return x)
complement! (opposite of intersect!: returns whats only in a but not also b)
issubset?
disjont
'=='
=#
