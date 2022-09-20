import Base: *, ==

# standard or user defined constants

const ISBN10RGX = r"^\d{1}-?\d{3}-?\d{5}-?(\d{1}|X{1})$" # type declaration on global variables only Julia > 1.8

const ISBN13RGX = r"\d{3}-?\d{1}-?\d{3}-?\d{5}-?\d{1}$"	# type declaration on global variables only Julia > 1.8

# error messages

const ERR(x,s) = throw(DomainError(x, s))	# type declaration on global variables only Julia > 1.8

const RGX_ERR(x;e=ERR) = e(x,"regex for type not defined")

const T_ERR(x;e=ERR) = e(x,"method for type not defined")

const STR_ERR(x;e=ERR) = e(x,"input not a valid ISBN string")

const NO_ERR(x;e=ERR) = e(x,"not a valid ISBN number")

# ISBN hierarchy

abstract type ISBN end

struct ISBN10 <: ISBN
	isbn::String
end

struct ISBN13 <: ISBN
	isbn::String
end

# constructors

ISBN(s::String)::ISBN = getSubtype(s) |> i -> i() |> return i

# traits

abstract type ISBNRgx end

struct ISBN10Rgx <: ISBNRgx end

struct ISBN13Rgx <: ISBNRgx end

ISBNRgx(::T) where {T} = T_ERR(T)

ISBNRgx(::Type{T}) where {T} = RGX_ERR(T)

ISBNRgx(::Type{ISBN10})::Regex = ISBN10RGX

ISBNRgx(::Type{ISBN13})::Regex = ISBN13RGX

# accessors

readISBN(::T) where {T} = T_ERR(T)

readISBN(::Type{T}) where {T} = T_ERR(T)

readISBN(i::ISBN) = i.isbn

# helper functions

doesMatch(i::Type{<:ISBN},str::String)::Union{RegexMatch,Nothing} = match(ISBNRgx(i),str)
# alternative:
# doesMatch(::Type{T} where {T <:ISBN},str::String)::Union{RegexMatch,Nothing} = match(ISBNRgx(T),str)

cleanStr!(str::String)::String = filter(s -> !ispunct(s), str)

cleanStr!(ss::SubString{String})::String = filter(s -> !ispunct(s), String(ss))

isValidStr(v::Vector;err::Function=STR_ERR) = isempty(v) ? err(v) : v

isValidStr(::Type{T};err::Function=T_ERR) where {T} = err(T)

isValidStr(m::RegexMatch;i::Type{<:ISBN},kwargs...)::ISBN = i(cleanStr!(m.match))

isValidStr(::Nothing;s::String,t::Vector,kwargs...)::ISBN= getSubtype(s,t)

# slightly 'dirty' hack as exercism environment does not import InteractiveUtils.subtypes as the default behavior for the Julia REPL
isbn_subtypes(stype::DataType)::Vector = [isbn for isbn in eval.(names(Main)) if typeof(isbn) == DataType && isbn <: stype && isbn != stype]

function getSubtype(s::String,
		    t::Vector=isbn_subtypes(ISBN);
		    dm::Function=doesMatch,
		    vs::Function=isValidStr
		   )::ISBN
	vs(t) |>
	pop! |> 
	r -> dm(r,s) |>  
	m -> vs(m;i=r,s=s,t=t)	

end

nochar2int(c::Char)::Int = isnumeric(c) ? parse(Int, c) : convert(Int, c)

isX10(c::Char)::Int = ifelse(c=='X',10,nochar2int(c))

isX10(c::String)::Int = ifelse(c=="X",10,nochar2int(c))

function (t::ISBN10)(;isX10::Function=isX10,e::Function=NO_ERR)
	readISBN(t) |>
	s -> ((sum(s[1:end-1] * [length(s):-1:2]) + 
	       	isX10(s[end])) % 11 != 0) && e(s)	
end

function (t::ISBN13)(;e::Function=NO_ERR)
	readISBN(t) |>
	s -> (sum(s * repeat([1,3],7)[1:13]) % 10 != 0) && e(s)	
end

# 'overloaded' functions

*(x::AbstractString, y::AbstractVector)::Vector{Int} = x * y

*(x::AbstractString, y::Vector{Integer})::Vector{Int} = collect(x) .* collect(y)

*(x::AbstractString, y::Vector{<:AbstractVector})::Vector{Int} = collect(x) .* Iterators.flatten(y)

*(x::AbstractChar, y::Int)::Int = nochar2int(x) * y

*(x::String, y::Int)::Int = nochar2int(only(x)) * y

==(x::T,y::T) where {T <: ISBN} = readISBN(x) == readISBN(y)

==(x::ISBN10,y::ISBN13) = readISBN(x)[begin:end-1] == readISBN(y)[begin+3:end-1]

==(x::ISBN13,y::ISBN10) = readISBN(x)[begin+3:end-1] == readISBN[begin:end-1]
