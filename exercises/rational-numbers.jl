import Base:  +, -, *, ^, /, <, ==, convert, promote, promote_rule

abstract type AbstractRationalNumber <: Real end

struct RationalNumber{T<:Integer} <: AbstractRationalNumber
    n::T
    d::T

    function RationalNumber{T}(n::T, d::T) where {T<:Integer}
        ZeroRational(n, d)
        n, d = flipsign(n, d), flipsign(d, d)
        g = gcd(n, d)
        new{T}(div(n, g), div(d, g))
    end
end

RationalNumber(n::T, d::T) where {T<:Integer} = RationalNumber{T}(n, d)

RationalNumber(n::Integer, d::Integer) = RationalNumber(promote(n, d)...)

RationalNumber(n::Integer) = RationalNumber(n, one(n))

RationalNumber(rn::RationalNumber, i::Integer) = RationalNumber(rn.n, (rn.d*i))

RationalNumber(i::Integer, rn::RationalNumber) = RationalNumber((i*rn.n), rn.d)

struct IsNull{T} end

IsNull(x::Integer) = IsNull{x == 0}()

struct ZeroRational{T} end

ZeroRational(n::Integer, d::Integer) = ZeroRational(IsNull(n),IsNull(d))

ZeroRational(::IsNull{true}, ::IsNull{true}) = throw(ArgumentError("invalid rational: 0//0"))

ZeroRational(n::IsNull, d::IsNull) = false

struct NegRatExp{T} end

NegRatExp(rn::RationalNumber) = NegRatExp{(rn.n < 0)}()

# -------------------------------------------------------------------------------------------

numerator(rn::RationalNumber) = rn.n

Base.denominator(rn::RationalNumber) = rn.d

Base.zero(::Type{RationalNumber{T}}) where {T<:Integer} = RationalNumber(0)

Base.one(::Type{RationalNumber{T}}) where {T<:Integer} = RationalNumber(1)

+(x::RationalNumber, z::RationalNumber...) = _op(x, z...; fct = +)

-(x::RationalNumber, y::RationalNumber) = _op(x, y; fct = -)

function _op(x::RationalNumber, y::RationalNumber, z::RationalNumber...;
             fct::Function)
    _op(_op(x, y; fct = fct), z...; fct = fct)
end

function _op(x::RationalNumber, y::RationalNumber; fct::Function)
    any(iszero, (x.d, y.d)) && (return RationalNumber(1, 0))
    (z = lcm(x.d, y.d)) |> 
    l -> map(rn -> rn.n * div(l, rn.d), (x, y)) |> 
    nn -> fct(nn...) |>
    n -> RationalNumber(n, z)
end

function Base.isless(x::RationalNumber, y::RationalNumber)
    x.d == y.d && return x.n < y.n
    isless((x.n * y.d), (y.n * x.d))  # cross multiplication
    #=
    Alternative:
    (a.n, a.d) < (b.n, b.d)
    =#
end

Base.convert(::Type{RationalNumber}, i::Integer) = RationalNumber(i)

Base.promote_rule(::Type{<:RationalNumber}, ::Type{<:Integer}) = RationalNumber

==(rnx::RationalNumber,rny::RationalNumber) = rnx.n == rny.n && rnx.d == rny.d

==(rn::RationalNumber, i::Integer) = (rn.d == 1) && (rn.n == i)

<(x::RationalNumber, y::RationalNumber) = isless(x, y)

<(rn::RationalNumber, i::Integer) = <(promote(rn, i)...)

*(x::RationalNumber, y::RationalNumber...) = *(x, y, z...)

*(x::RationalNumber, y::RationalNumber, z::RationalNumber...) = *(*(x, y), z...)

function *(x::RationalNumber, y::RationalNumber)
    n = x.n * y.n
    d = x.d * y.d
    return RationalNumber(n, d)
end

Base.inv(rn::RationalNumber) = RationalNumber(rn.d, rn.n)

/(x::RationalNumber, y::RationalNumber) = x * inv(y)

^(rn::RationalNumber, i::Integer) = RationalNumber((rn.n ^ i), (rn.d ^ i))

^(i::Integer, rn::RationalNumber) = _pow(NegRatExp(rn), i, rn)

_pow(::NegRatExp{false}, i::Integer, rn::RationalNumber) = (i ^ rn.n) ^ (1 / rn.d)

function _pow(::NegRatExp{true}, i::Integer, rn::RationalNumber)
    a = abs(rn.n)
    1 / (i ^ a) ^ (1 / rn.d)
end

Base.isapprox(rn::RationalNumber, r::Real) = isapprox((rn.n / rn.d), r)

Base.abs(rn::RationalNumber) = RationalNumber(abs(rn.n), rn.d)

function Base.show(io::IO, rn::RationalNumber)
    show(io, numerator(rn))
    print(io, "//")
    show(io, denominator(rn))
end
