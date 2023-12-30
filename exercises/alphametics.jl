# alphametics solver using backtracking

const rvalidInput = r"^[A-Z]+(\ ?\+\ ?[A-Z]+)*\ ?\=\=\ ?[A-Z]+$"

# mutable fields of `Alphametic`

mutable struct Solution
    snapshot::Dict{Char, Union{Int, Missing}}
end

Solution(s::String) = Dict(c => missing for c in s if isletter(c)) |> Solution

mutable struct Position
    current::Int
    Position(p::Int = 0) = new(p)
end

# helper function for Alphametic constructor

firstchar(s::String) = Set(s[first(i)] for i in findall(r"[A-Z]+", s))

# `Alphametic`

struct Alphametic
    puzzle::String
    elements::Tuple{Char, Vararg{Char}}
    first::Set{Char}
    position::Position
    current::Solution
end

Alphametic(::Nothing) = nothing

function Alphametic(s::String)
    Solution(s) |> 
    d -> Alphametic(s, (keys(d.snapshot)...,), firstchar(s), Position(), d)
end

# helper functions for `solve()`

validInputString(s::String; r::Regex=rvalidInput) = match(r, s) |> validInputString

validInputString(m::RegexMatch) = String(m.match) # otherwise returns type substring

validInputString(n::Nothing) = n

function validSet(s::String)
    Set(i for i in s if isletter(i)) |>
    (c -> length(c) <= 10) |> 
    v -> validSet(Val(v), s)
end

validSet(::Val{true}, s) = s

validSet(::Val{false}, _) = nothing

validSet(n::Nothing) = n

# `solve()`

function solve(s::String) 
    validInputString(s) |> 
    validSet |> 
    Alphametic |> 
    solve
end

solve(n::Nothing) = n

solve(a::Alphametic) = backtrack(a)

# helper functions for backtracking

function Base.allunique(a::Alphametic)
    values(a.current.snapshot) |>
    skipmissing |>
    allunique
end

iscomplete(a::Alphametic) = values(a.current.snapshot) |> x -> !any(ismissing, x)

function firstzero(a::Alphametic)
    any(i -> (c = a.current.snapshot[i]; ismissing(c)) ? false : iszero(c), a.first)
end

function isvalidSolution(a::Alphametic)
    replace(a.puzzle, pairs(a.current.snapshot)...) |> 
    Meta.parse |>
    eval
end

reject(a::Alphametic) = !allunique(a) || firstzero(a)

accept(a::Alphametic) = iscomplete(a) && isvalidSolution(a)

function start(a::Alphametic)
    a.position.current == length(a.elements) ? nothing : 
        begin 
            a.position.current += 1
            a.current.snapshot[a.elements[a.position.current]] = 0
            return a
        end
end

function next(a::Alphametic)
    a.current.snapshot[a.elements[a.position.current]] == 9 ? 
        begin
            a.current.snapshot[a.elements[a.position.current]] = missing
            a.position.current -= 1 
            return nothing
        end : 
        begin
            a.current.snapshot[a.elements[a.position.current]] += 1
            return a
        end
end

# backtracking

function backtrack(a::Alphametic)
    reject(a) && return
    accept(a) && return a.current.snapshot
    s = start(a)
    while !isnothing(s)
        (b = backtrack(s); isnothing(b)) ? (s = next(s)) : return b
    end
    return nothing
end

#=

# notes 

# minimal working examples for backtracking options

# wikipedia approach

r(v::Vector) = !allunique(v)

a(v::Vector) = v == [5,3,1]

f(v::Vector) = length(v) == 3 ? nothing : append!(v,0)

function n(v::Vector)
    v[end] == 5 && (pop!(v); return nothing)
    v[end] += 1
    return v
end

function bt(v::Vector)
    r(v) && return
    a(v) && println("bingo")
    s = f(v)
    while !isnothing(s)
        bt(s)
        s = n(s)
    end
end

# 'naive' backtracking

function bt(k,t=[],r=[])
    k == 0 && (push!(r,copy(t)); return)  # `copy()` essential
    for e in 0:9
        if !(e in t)
            push!(t,e)
            bt(k-1,t,r)
            pop!(t)
        end
    end
    return r
end

# generator comprehension

function generator(k::Int,n::Int=0)
    k == 0 && return [Int[]]
    return (append!([i],c) for i in n:9 for c in generator(k-1,n=n) if !(i in c))
end

generator(3) |> 
x -> Iterators.filter(isvalidSolution) |> 
first # or: y -> Iterators.take(y,1)
=#
