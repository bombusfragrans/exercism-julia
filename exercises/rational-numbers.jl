import Base:  +, -, *, ^, /, < 

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

struct IsNull{T} end

IsNull(x::Integer) = IsNull{x == 0}()

struct ZeroRational{T} end

ZeroRational(n::Integer, d::Integer) = ZeroRational(IsNull(n),IsNull(d))

ZeroRational(::IsNull{true}, ::IsNull{true}) = throw(ArgumentError("invalid rational: 0//0"))

ZeroRational(n::IsNull, d::IsNull) = false

RationalNumber(n::T, d::T) where {T<:Integer} = RationalNumber{T}(n, d)

RationalNumber(n::Integer, d::Integer) = RationalNumber(promote(n, d)...)

RationalNumber(n::Integer) = RationalNumber(n, one(n))

RationalNumber(rn::RationalNumber, i::Integer) = RationalNumber(rn.n, (rn.d*i))

RationalNumber(i::Integer, rn::RationalNumber) = RationalNumber((i*rn.d), rn.n)

numerator(rn::RationalNumber) = rn.n

denominator(rn::RationalNumber) = rn.d

Base.isequal(rnx::RationalNumber,rny::RationalNumber) = rnx.n == rny.n && rnx.d == rny.d

Base.zero(rn::RationalNumber{T}) where {T<:Integer} = zero(T)

Base.one(rn::RationalNumber{T}) where {T<:Integer} = one(T)

+(rn::RationalNumber...) = _op(x, y, z...; fct = +)

-(x::RationalNumber, y::RationalNumber) = _op(x, y; fct = -)

function _op(x::RationalNumber, y::RationalNumber, z::RationalNumber...;
             fct::Function)
    _op(_op(x, y; fct = fct), z...; fct = fct)
end

function _elevate(x::RationalNumber, y::RationalNumber)
    z = lcm(x.d, y.d)
    a = x.n * div(z, x.d)
    b = y.n * div(z, y.d)
    return (a, z), (b, z)
end

function _op(a::RationalNumber, b::RationalNumber; fct::Function, _e::Function = _elevate)
    x, y = _e(a, b)
    n = fct(x[1], y[1])
    return RationalNumber(n, x[1])
end

function Base.isless(a::RationalNumber, b::RationalNumber; _e::Function = _elevate)
    x, y = _e(a, b)
    isless(x, y)
    #=
    Alternative:
    (a.n, a.d) < (b.n, b.d)
    =#
end

<(x::RationalNumber, y::RationalNumber) = isless(x, y)

*(x::RationalNumber, y::RationalNumber...) = *(x, y, z...)

*(x::RationalNumber, y::RationalNumber, z::RationalNumber...) = *(*(x, y), z...)

function *(x::RationalNumber, y::RationalNumber)
    n = x.n * y.n
    d = x.d * y.d
    return RationalNumber(n, d)
end

Base.inv(rn::RationalNumber) = RationalNumber(rn.d, rn.n)

/(x::RationalNumber, y::RationalNumber) = x * inv(y) 

^(rn::RationalNumber, i::Integer) = RationalNumber(rn.n, (rn.d ^ i))

#Base.show(io::IO, rn::RationalNumber) = "$rn.n//$rn.d"

#Base.sprint()
