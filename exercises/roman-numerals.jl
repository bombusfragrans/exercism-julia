function to_roman(number::Int,
		prefix1=('M','C','X','I'),
		prefix5=(missing,'D','L','V'))::AbstractString

	number <= 0 && throw(ErrorException("Number needs to be larger than zero"))

	prefix4 = prefix1 .* prefix5
	prefix9 = [missing;prefix1[begin+1:end] .* prefix1[begin:end-1]...]

	numeric = reverse(digits(number,base=10,pad=length(prefix1)))

	join(map(enumerate(numeric)) do (i,x)
		x == 0 && return ""
		x == 4 && return prefix4[i]
		x == 5 && return prefix5[i]
		x == 9 && return prefix9[i]
		x <= 3 && return prefix1[i]^x
		return prefix5[i] * prefix1[i]^(x-5)
	end)
end

#=
# Alternative solution:
using Julia package RomanNumerals.jl and e.g. string literals therein
=#
