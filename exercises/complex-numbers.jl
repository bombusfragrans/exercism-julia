import Base: +, -, *, /, ^

abstract type AbstractComplexNumber <: Number end

struct ComplexNumber{T <: Real} <: AbstractComplexNumber
    re::T
    im::T
end

ComplexNumber(x::Real, y::Real) = Complex(promote(x,y)...)

ComplexNumber(x::Real) = Complex(x, zero(x))

real(cn::ComplexNumber) = cn.re

imag(cn::ComplexNumber) = cn.im

conj(cn::ComplexNumber) = ComplexNumber(cn.re, -(cn.im))

Base.abs(cn::ComplexNumber) = sqrt((cn.re ^ 2) + (cn.im ^ 2))

Base.isequal(cnx::ComplexNumber, cny::ComplexNumber) = cnx.re == cny.re && cnx.im == cny.im

function Base.isapprox(cnx::ComplexNumber, cny::ComplexNumber)
    isapprox(cnx.re, cny.re) && isapprox(cnx.im, cny.im)
end

+(cnx::ComplexNumber, cny::ComplexNumber) = ComplexNumber((cnx.re + cny.re), (cnx.im + cny.im))

-(cnx::ComplexNumber, cny::ComplexNumber) = ComplexNumber((cnx.re - cny.re), (cnx.im - cny.im))

function *(cnx::ComplexNumber, cny::ComplexNumber)
    ComplexNumber((cnx.re * cny.re - cnx.im * cny.im),
                  (cnx.im * cny.re + cnx.re * cny.im))
end

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
    const r = abs(cn)
    const r_pow_n(r, n) = r ^ n
    const arg = tan(cn.im / cn.re) ^ -1
    const rpn = r_pow_n(r, i)
    const cn_pow_n(n, arg) = ((rpn * cos(n * arg)), (rpn * sin(n * arg)))
    ComplexNumber(cn_pow_n(i, arg)...)
end

#exp(cn::ComplexNumber) = ComplexNumber()

#jm()

#Base.show()
