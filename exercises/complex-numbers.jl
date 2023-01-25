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

#^(cn::ComplexNumber, i::Integer) = 

#=
If a,b are real, then a+ib=r(cosθ + i sinθ) where r=sqrt(a^2+b^2) and tan θ=b/a, and
(a + i b)^N = r^N(cos(Nθ) + i sin(Nθ)).
r = abs(ComplexNumber)
θ = π/4
=#

#exp(cn::ComplexNumber) = ComplexNumber()

#Base.show()
