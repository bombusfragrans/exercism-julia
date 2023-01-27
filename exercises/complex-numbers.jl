import Base: +, -, *, /, ^

abstract type AbstractComplexNumber <: Number end

struct ComplexNumber{T <: Real} <: AbstractComplexNumber
    re::T
    im::T
end

struct jm <: AbstractComplexNumber
    cn::ComplexNumber
end

ComplexNumber(x::Real, y::Real) = ComplexNumber(promote(x, y)...)

ComplexNumber(x::Real) = ComplexNumber(x, zero(x))

jm(x::Real, y::Real) = jm(ComplexNumber(x, y))

jm(x::Real) = jm(ComplexNumber(zero(x), x))

convert(::Type{ComplexNumber}, j::jm) = j.cn

Base.promote_rule(::Type{jm}) = ComplexNumber

Base.promote_rule(::Type{<:AbstractComplexNumber}, ::Type{<:AbstractComplexNumber}) = ComplexNumber

real(cn::ComplexNumber) = cn.re

imag(cn::ComplexNumber) = cn.im

conj(cn::ComplexNumber) = ComplexNumber(cn.re, -(cn.im))

Base.abs(cn::ComplexNumber) = sqrt((cn.re ^ 2) + (cn.im ^ 2))

Base.isequal(cnx::ComplexNumber, cny::ComplexNumber) = cnx.re == cny.re && cnx.im == cny.im

Base.isequal(cn::ComplexNumber, j::jm) = cn == j.cn

Base.isequal(j::jm, cn::ComplexNumber) = isequal(promote(j, cn)...)

function Base.isapprox(cnx::ComplexNumber, cny::ComplexNumber)
    isapprox(cnx.re, cny.re) && isapprox(cnx.im, cny.im)
end

+(cnx::ComplexNumber, cny::ComplexNumber) = ComplexNumber((cnx.re + cny.re), (cnx.im + cny.im))

+(r::Real, j::jm) = jm(r, j.cn.im)

-(cnx::ComplexNumber, cny::ComplexNumber) = ComplexNumber((cnx.re - cny.re), (cnx.im - cny.im))

function *(cnx::ComplexNumber, cny::ComplexNumber)
    ComplexNumber((cnx.re * cny.re - cnx.im * cny.im),
                  (cnx.im * cny.re + cnx.re * cny.im))
end

*(r::Real, ::Type{jm}) = jm(r)

function /(cnx::ComplexNumber, cny::ComplexNumber)
    ComplexNumber((cnx.re * cny.re + cnx.im * cny.im) / 
                  (cny.re ^ 2 + cny.im ^ 2),
                  (cnx.im * cny.re - cnx.re * cny.im) /
                  (cny.re ^ 2 + cny.im ^ 2))
end

function ^(cn::ComplexNumber, i::Integer)
    i == 0 && return ComplexNumber(cn.re ^ 0, cn.im ^ 0)
    i == 1 && return cn
    i == 2 && return ComplexNumber((cn.re ^ 2 − cn.im ^ 2), (2 * cn.re * cn.im))
    #DeMoivre: r ^ n * (cos(n * arg) + sin(n * arg)i)
    arg = tan(cn.im / cn.re) ^ -1
    rpn = abs(cn) ^ i
    ComplexNumber((rpn * cos(i * arg)), (rpn * sin(i * arg)))
end

^(j::jm, i::Integer) = ^(promote(j), i)

function exp(cn::ComplexNumber)
    m = exp(cn.re)
    ComplexNumber((m * cos(cn.im)), (m * sin(cn.im)))
end

function Base.show(io::IO, cn::ComplexNumber)
    show(io, cn.re)
    print(io, " + ")
    show(io, cn.im)
    print(io, "i")
end

function Base.show(io::IO, j::jm)
    show(io, j.cn.re)
    print(io, " + ")
    show(io, j.cn.im)
    print(io, "jm")
end
