# RationalNumber{{Int}(numerator,denominator) <: Real
# RationalNumber(0, 0) => ArgumentError
# implements +,-,*,^,/,==, !=, <=, >=, <, >,
# zero, one, show, sprint
# numerator,
# denominator
# if denominator < o multiply all with -1
# always return values based on gcd()

abstract type AbstractRationalNumber <: Real end

struct RationalNumber{T<:Integer} <: AbstractRationalNumber
    n::T
    d::T

    function RationalNumber(n::T, d:T) where {T<:Integer}
        ZeroRational(n, d)
        n, d = flipsign(n, d), flipsign(n, d)
        g = gcd(n, d)  
        new(div(n, g), div(d, g))
    end
end

struct IsNull{T} end

IsNull(x::Integer) = IsNull{x == 0}()

struct ZeroRational{T} end

ZeroRational(n::Integer, d::Integer) = ZeroRational(IsNull(n),IsNull(d))

ZeroRational(::IsNull{true}, ::IsNull{true}) = throw(ArgumentError("invalid rational: 0//0"))

ZeroRational(n::IsnNull, d::Isnull) = false

RationalNumber(n::T, d::T) where {T<:Integer} = RationalNumber{T}(n, d)

RationalNumber(n::Integer, d::INteger) = RationalNumber(promote(n, d)...)

RationalNumber(n::Integer) = RationalNumber(n, one(n))

RationalNumber(rn::RationalNumber, i::Integer) = RationalNumber(rn.n, (rn.d*i))

RationalNumber(i::Integer, rn::RationalNumber) = RationalNumber((i*rn.d), rn.n)
