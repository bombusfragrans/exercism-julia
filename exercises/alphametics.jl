# alphametics solver using backtracking

const rvalidInput = r"^[A-Z]+(\ ?\+\ ?[A-Z]+)*\ ?\=\=\ ?[A-Z]+$"

struct Alphametic
    left::Vector{String}
    right::String
    current::Solution
end

function Alphametic(s::String)
    fs = split(s, "==")
    Alphametic(strip.(isspace, split(fs, "+")), strip(isspace, last(fs)), Solution(s))
end

mutable struct Solution
    snapshot::Dict{Char, Union{Int, Missing}}
end

Solution(s::String) = Solution(Dict(collect(filter(isletter, s)) .=> missing))
# Remark: optionally `filter` could be replaced by `collect(s)[isletter.(collect(s)]`

Solution(s::Set{Char}) = Solution(Dict(s .=> missing))

Base.length(S::Solution) = length(S.snapshot)

# types and constructor for dispatch on `swap()`

abstract type Site end

struct Left end

struct Right end

Site(s::Symbol) = Dict(:left => Left(), :right => Right())[s] # to ensure that only `;left` or `:right` are accepted
# alternative; `s == :left ? Left() : Right()` 
# alternative: `(s == :left && return Left()) || return Right()`

# helper functions for `solve()`

validInputString(s::String; vi::Regex=rvalidInput) = isnothing(match(vi, s)) ? nothing : s

function validSet(s::Union{String, Nothing})
    isnothing(s) && return nothing
    length(Set(filter(isletter, s))) <= 10 ? s : nothing
end
    
not_taken(a::Alphametic, n::Int) = !(n in values(a.current.snapshot))

non_missing(a::Alphametic) = !any(ismissing, values(a.current.snapshot))

swap(a::Alphametic, site::Symbol) = swap(Site(site), a)

swap(::Left, a::Alphametic) = _swap(a.current.snapshot, a.left...)

swap(::Right, a::Alphametic) = _swap(a.current.snapshot, a.right)

_swap(d::Dict{Char, Int}, s::String...) = map(i -> _swap(d, i), s)

_swap(d::Dict{Char, Int}, s::String) = parse(Int, mapreduce(c -> string(d[c]), *, s))
# alternative: `sum(d[c] * 10 ^ (i - 1) for (i, c) inumerate(reverse(s)))`

isvalidSolution(a::Alphametic) = sum(_swap(a, :left)) == _swap(a, :right)

function solve(s::String) # calls _solve and returns a Dict or nothing
    s |> 
    validInputString |> 
    validSet |> 
    Alphametic |> 
    solve
end

function solve(a::Alphametic)
    for k,v in a.current.snapshot
        if v === missing
            for i in 0:9
                if not_taken(a, i)
                    a.current.snapshot[k] = i
                    if non_missing(a)
                        isvalidSolution(a) ? return a.current.snapshot : a.current.snapshot[k] = missing  # |> solve???
                    else
                        solve(a)
                    end    
                end
            end
        end
    end
end # the solver itself
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

sanity checks
    A == B => nothing (not an unique solution for each letter)
    solutions with leading zero in right hand side => nothing
dispatch on validSolution:
    holy trait pattern
    requires a struct
    requires a private function _validSolution which returns a bool
        => true: continue, false: backtrack
create an iterator / lazy generator to iterate over permutations
    requires a struct
    requires to conditioned on already known solutions
main data container
    constructor splits input text in left & right
    left is subsplit into subsegments
    references mutable struct of known solutions
dict to track and update current solutions
    requires a (mutable) struct
    constrains / conditions permutation iterator
=#

# https://www.youtube.com/watch?v=G_UYXzGuqvM
