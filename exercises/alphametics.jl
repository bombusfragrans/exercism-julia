# alphametics solver using backtracking

const rvalidInput = r"^[A-Z]+(\ ?\+\ ?[A-Z]+)*\ ?\=\=\ ?[A-Z]+$"

# nedded for `Alphametic`

mutable struct Solution
    snapshot::Dict{Char, Union{Int, Missing}}
end

Solution(s::String) = Solution(Dict(collect(filter(isletter, s)) .=> missing))
# Remark: optionally `filter` could be replaced by `collect(s)[isletter.(collect(s)]`

Solution(s::Set{Char}) = Solution(Dict(s .=> missing))

Base.length(S::Solution) = length(S.snapshot)

struct Alphametic
    left::Vector{String}
    right::String
    current::Solution
end

function Alphametic(s::String)
    fs = split(s, "==")
    Alphametic(strip.(isspace, split(first(fs), "+")), strip(isspace, last(fs)), Solution(s))
end

Alphametic(::Nothing) = nothing

# types and constructor for dispatch on `swap()`

abstract type Site end

struct Left end

struct Right end

Site(s::Symbol) = Dict(:left => Left(), :right => Right())[s] # to ensure that only `;left` or `:right` are accepted
# alternative; `s == :left ? Left() : Right()` 
# alternative: `(s == :left && return Left()) || return Right()`

# helper functions for `solve()`

validInputString(s::String; vi::Regex=rvalidInput) = validInputString(match(vi, s))

validInputString(m::RegexMatch) = m.match

validInputString(n::Nothing) = n

validSet(s::String) = validSet(Val(length(Set(filter(isletter, s))) <= 10), s)

validSet(::Val{true}, s) = s

validSet(::Val{false}, _) = nothing

validSet(n::Nothing) = n
    
not_taken(a::Alphametic, n::Int) = !(any(v -> !ismissing(v) && v == n, values(a.current.snapshot)))

non_missing(a::Alphametic) = !any(ismissing, values(a.current.snapshot))

swap(a::Alphametic, site::Symbol) = swap(Site(site), a)

swap(::Left, a::Alphametic) = _swap(a.current.snapshot, a.left...)

swap(::Right, a::Alphametic) = _swap(a.current.snapshot, a.right)

_swap(d::Dict{Char, Union{Missing, Int}}, s::String...) = map(i -> _swap(d, i), s)

_swap(d::Dict{Char, Union{Missing, Int}}, s::String) = parse(Int, mapreduce(c -> string(d[c]), *, s))
# alternative: `sum(d[c] * 10 ^ (i - 1) for (i, c) inumerate(reverse(s)))`

isvalidSolution(a::Alphametic) = sum(swap(a, :left)) == swap(a, :right)
# TODO: tested up to here
# experimental exercise: 
# using dispatch and recursion for `solve()` instead of otherwise e.g. nested loops

function solve(s::String) 
    # solve #1
    s |> 
    validInputString |> 
    validSet |> 
    Alphametic |> 
    solve # passed to solve #2(a/b)
end

solve(n::Nothing) = n # solve #2a

function solve(a::Alphametic)
    # solve #2b
    non_missing(a) && isvalidSolution(a) && return a
    d = a.current,snapshot
    k, v = collect(keys(d)), collect(values(d))
    solve(a, k, v)  # passed to solve #3
end

function solve(a::Alphametic, k::Vector{Char}, v::Vector{Int})
    # solve #3
    isempty(k) && return nothing
    solve(a, first(k), first(v))  # passed to solve #4(a/b)
    solve(a, k[2:end], v[2:end])  # recursion to solve #3
end

solve(a::Alphametic, k::Char, v::Int) = nothing # solve #4a

solve(a::Alphametic, k::Char, v::Missing) = solve(a, k) # solve #4b passed on to solve #5

function solve(a::Alphametic, k::Char, r::Vector{Int}=collect(0:9))
    # solve #5
    isempty(r) && return nothing
    i = first(r)
    solve(Val(not_taken(a, i)), a, i) # passed to solve #6(a/b)
    solve(a, k, r[2:end]) # recursion to solve #5
end

solve(::Val{false}, _, __) = nothing  # solve #6a

function solve(::Val{true}, a::Alphametic, k::Char, i::Int)
    # solve #6b
    a.current.snapshot[k] = i
    solve(a)  # recursion to solve #2b
    a.current.snapshot[k] = missing
end

#=
function findCombinations(k::Int, N::Vector{Int}=collect(0:9),
            )::Vector{Vector{Int}}

    k < 1 && return [Int[]]

	rereturn [append!([x],z) for x in N
		for for z in findCombinations(k-1, N[begin+1:end])
		if !if !(x in z)]
    end
=#

#=
3. for each column (from the back) try a permutation of n out of 0-9 where x + y = z
4. check whether they are a solution
5. constrain on letter substitutions already known
6. backtrack if no valid solution
7. output: dict with subsitution mappings

------

create an iterator / lazy generator to iterate over permutations
    requires a struct
    requires to conditioned on already known solutions
=#

# https://www.youtube.com/watch?v=G_UYXzGuqvM
