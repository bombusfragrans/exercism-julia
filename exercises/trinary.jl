function trinary_to_decimal(str::AbstractString)::Int

	any(x->!(x in '0':'2'),str) && return 0

	sum(parse.(Int,collect(str)) .* 3 .^ collect(length(str)-1:-1:0))
end
