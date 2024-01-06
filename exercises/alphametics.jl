include("permutations.jl")

function swap(d::Dict{Char, Int})
    word::SubString{String} -> 
        foldl((i, k) -> 10 * i + d[k], word; init = 0)
end
        
function solve(s::String)
    w = split(s, !isletter, keepempty = false)
    l = collect.(w) |> Iterators.flatten |> unique
    f = first.(w) |> unique

    for p in permutations(0:9, length(l))
        s = Dict(zip(l, p))
        any(i -> iszero(s[i]), f) && continue
        r = swap(s).(w) 
        (sum(r[1:end - 1]) == r[end]) && return s
    end

    nothing

end

#=

#########################################################

# for ducumentation purposes only!
# slower previous implementation versions
# tried to come up with an alternative implementation...

#########################################################

=#

#=

#------------------------------------------

# alphametics solver using Iterators utils
# based on faster `isvalidSolutio()`
# passed all tests locally under 10s
# still times out on exercism ;-(

#-----------------------------------------

include("permutations.jl")

firstzero(f::Vector{Char}) = d::Dict{Char, Int} -> any(i -> iszero(d[i]), f)

function swap(d::Dict{Char, Int})
    word::SubString{String} -> 
        Iterators.foldl((i, k) -> 10 * i + d[k], word; init = 0)
end
        
function check(w::Vector{SubString{String}})
    d::Dict{Char, Int} -> 
    swap(d).(w) |> 
    (n -> sum(n[1:end - 1]) == n[end])
end

function solution(f::Function, c::Function)
    d::Dict{Char, Int} -> 
    !f(d) && c(d) 
end

function solve(s::String)
    w = split(s, !isletter, keepempty = false)
    l = collect.(w) |> Iterators.flatten |> unique
    f = first.(w) |> unique

    e = solution(firstzero(f), check(w))    

    Iterators.map(p -> Dict(zip(l,p)), permutations(0:9, length(l))) |> 
    s -> Iterators.filter(e, s) |> 
    r -> Iterators.take(r, 1) |> 
    i -> isempty(i) ? nothing : first(i)

end

=#

#=

#----------------------------------------

# alphametics solver using iterator
# based on faster `isvalidSolutio()`
# passed all tests locally under 10s
# still times out on exercism ;-(

#---------------------------------------

include("permutations.jl")

struct Alphametic
    letters::Vector{Char}
    candidates::Permutations{UnitRange{Int}}
end

function Alphametic(l::Vector{Char})
    p::Permutations{UnitRange{Int}} -> 
    Alphametic(l, p)
end

words(s::String) = split(s, !isletter, keepempty = false)

letters(s::Vector{SubString{String}}) = union.(s...) 

firstchar(s::Vector{SubString{String}}) = first.(s) |> unique

firstzero(f::Vector{Char}) = d::Dict{Char, Int} -> any(i -> iszero(d[i]), f)

function swap(d::Dict{Char, Int})
    word::SubString{String} -> 
        foldl((i, k) -> 10 * i + d[k], word; init = 0)
end

function check(w::Vector{SubString{String}})
    d::Dict{Char, Int} -> 
    swap(d).(w) |> 
    (n -> sum(n[1:end - 1]) == n[end])
end

function solution(f::Function, c::Function)
    d::Dict{Char, Int} -> 
    !f(d) && c(d) 
end

function _iterate(a::Alphametic, i::NTuple{2, Vector{Int}})
    isnothing(i) && return nothing
    return Dict(a.letters .=> i[1]), i[2]
end

_iterate(::Alphametic, ::Nothing) = nothing

Base.iterate(a::Alphametic) = iterate(a.candidates) |> i -> _iterate(a, i)

function Base.iterate(a::Alphametic, state::Vector{Int})
    iterate(a.candidates, state) |>
    i -> _iterate(a, i)
end

Base.length(a::Alphametic) = length(a.candidates)

function _solve(f::Function)
    a::Alphametic -> 
    Iterators.filter(f, a) |> 
    r -> Iterators.take(r, 1) |> 
    i -> isempty(i) ? nothing : first(i)
end

function solve(s::String)
    w = words(s)
    l = letters(w)
    _s = firstchar(w) |> firstzero |> f -> solution(f, check(w)) |> _solve
    permutations(0:9, length(l)) |> 
    Alphametic(l) |> 
    _s
end

=#

#=

#----------------------------------------

# alphametics solver using backtracking
# based on faster `isvalidSolutio()`
# passed all tests locally under 10s
# still times out on exercism ;-(

#---------------------------------------

const rvalidInput = r"^[A-Z]+(\ ?\+\ ?[A-Z]+)*\ ?\=\=\ ?[A-Z]+$"

# mutable fields of `Alphametic`

mutable struct Solution
    current::Dict{Char, Union{Int, Missing}}
end

Solution(c::Vector{Char}) = Dict(c .=> missing) |> Solution

mutable struct Position
    current::Int
    Position(p::Int = 0) = new(p)
end

# `Alphametic` struct

struct Alphametic
    puzzle::String
    words::Vector{SubString{String}}
    letters::Vector{Char}
    first::Vector{Char}
    position::Position
    solution::Solution
end

# helper functions for constructor

validInputString(s::String; r::Regex=rvalidInput) = match(r, s)

words(::Nothing) = nothing

words(r::RegexMatch) = split(r.match, !isletter, keepempty = false)

validSet(n::Nothing) = n

function validSet(s::Vector{SubString{String}})
    union.(s...) |> 
    (l -> length(l) <= 10) |> 
    v -> validSet(Val(v), s)
end

validSet(::Val{true}, s::Vector{SubString{String}}) = s

validSet(::Val{false}, _) = nothing

firstchar(s::Vector{SubString{String}}) = first.(s) |> unique

# `Alphametic constructor

Alphametic(::Nothing) = nothing

function Alphametic(s::String)
    validInputString(s) |> 
    words |> 
    validSet |> 
    w -> Alphametic(s, w)
end

function Alphametic(s::String, w::Vector{SubString{String}})
    (l = union.(w...)) |> 
    Solution |> 
    d -> Alphametic(s, w, l, firstchar(w), Position(), d)
end

# `solve()`

solve(n::Nothing) = n

solve(s::String) = Alphametic(s) |> backtrack

# helper functions for backtracking

function Base.allunique(a::Alphametic)
    values(a.solution.current) |>
    skipmissing |>
    allunique
end

function firstzero(a::Alphametic)
    any(i -> (c = a.solution.current[i]; ismissing(c)) ? false : iszero(c), a.first)
end

complete(a::Alphametic) = values(a.solution.current) |> x -> !any(ismissing, x)

function swap(d::Dict{Char, Union{Missing, Int}})
    word -> foldl((i, k) -> 10 * i + d[k], word; init = 0)
end

function check(a::Alphametic)
    swap(a.solution.current).(a.words) |> 
    (n -> sum(n[1:end - 1]) == n[end])
end

reject(a::Alphametic) = !allunique(a) || firstzero(a)

accept(a::Alphametic) = complete(a) && check(a)

function start(a::Alphametic)
    a.position.current == length(a.letters) ? nothing : 
        begin 
            a.position.current += 1
            a.solution.current[a.letters[a.position.current]] = 0
            return a
        end
end

function next(a::Alphametic)
    a.solution.current[a.letters[a.position.current]] == 9 ? 
        begin
            a.solution.current[a.letters[a.position.current]] = missing
            a.position.current -= 1 
            return nothing
        end : 
        begin
            a.solution.current[a.letters[a.position.current]] += 1
            return a
        end
end

# backtracking

function backtrack(a::Alphametic)
    reject(a) && return
    accept(a) && return a.solution.current
    s = start(a)
    while !isnothing(s)
        (b = backtrack(s); isnothing(b)) ? (s = next(s)) : return b
    end
    return nothing
end

=#

#=

#---------------------------------------------------------

# alphametics solver based on an extended iterator
# passed all tests locally but timed out on exercism ;-(
# due to (~18x) slower `isvalidSolution()`
# slower than backtracking version below

#---------------------------------------------------------

include("permutations.jl")

const rvalidInput = r"^[A-Z]+(\ ?\+\ ?[A-Z]+)*\ ?\=\=\ ?[A-Z]+$"

# mutable fields of `Alphametic`

mutable struct Solution
    current::Dict{Char, Union{Int, Missing}}
end

Solution(c::Vector{Char}) = Dict(c .=> missing) |> Solution

Solution(d::Dict{Char, Int}) = Solution(d)

# `Alphametic` struct

struct Alphametic
    puzzle::String
    first::Vector{Char}
    candidates::Permutations{UnitRange{Int}}
    solution::Solution
end

# helper functions for constructor

validInputString(s::String; r::Regex=rvalidInput) = match(r, s)

words(r::RegexMatch) = eachmatch(r"[A-Z]+", r.match) |> m -> (i -> i.match).(m)

words(::Nothing) = nothing

letters(s::Vector{SubString{String}}) = union.(s...) 

function validSet(s::Vector{SubString{String}})
    letters(s) |> 
    (l -> length(l) <= 10) |> 
    v -> validSet(Val(v), s)
end

validSet(::Val{true}, s::Vector{SubString{String}}) = s

validSet(::Val{false}, _) = nothing

validSet(n::Nothing) = n

firstchar(s::Vector{SubString{String}}) = first.(s) |> unique

# `Alphametic constructor

Alphametic(::Nothing) = nothing

Alphametic(::String, ::Nothing) = nothing

function Alphametic(s::String)
    validInputString(s) |> 
    words |> 
    validSet |> 
    w -> Alphametic(s, w)
end

function Alphametic(s::String, w::Vector{SubString{String}})
    letters(w) |> 
    l -> Alphametic(s, firstchar(w), permutations(0:9, length(l)), Solution(l)) 
end

# iterator for `Alphametic`
# iterates over the permutations in Alphametic.next
# and returns an Alphametic with a new current Alphametic.solution

function _iterate(a::Alphametic, i::NTuple{2, Vector{Int}})
    isnothing(i) && return nothing
    a.solution.current = Dict(keys(a.solution.current) .=> i[1])
    return (a, i[2])
end

_iterate(::Alphametic, ::Nothing) = nothing

Base.iterate(a::Alphametic) = iterate(a.candidates) |> i -> _iterate(a, i)

function Base.iterate(a::Alphametic, state::Vector{Int})
    i = iterate(a.candidates, state) |>
    i -> _iterate(a, i)
end

Base.length(a::Alphametic) = length(a.candidates)

# helper functions for `solve()`

firstzero(a::Alphametic) = any(i -> iszero(a.solution.current[i]), a.first)

function check(a::Alphametic)
    replace(a.puzzle, a.solution.current...) |> 
    Meta.parse |>
    eval
end

isvalidSolution(a::Alphametic) = check(a) && !firstzero(a)

# `solve()`

function _solve(a::Alphametic)
    Iterators.filter(isvalidSolution, a) |> 
    r -> _solve(Val(isempty(r)), r)
end

_solve(::Val{false}, v) = first(v) |> d -> d.solution.current

_solve(::Val{true}, _) = nothing

solve(s::String) = Alphametic(s) |> a -> _solve(a)

=#

#=

#--------------------------------------------------------------

# alphametics solver using backtracking
# passed tests locally but last test timed out on exercism ;-(
# due to slower `isvalidSolution()`

#--------------------------------------------------------------

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

=#

#=

#---------------------------------------------------

# notes 

# minimal working examples for backtracking options

#---------------------------------------------------

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
x -> Iterators.filter(isvalidSolution, x) |> 
first # or: y -> Iterators.take(y,1)
=#
