function luhn(numberstring::AbstractString)::Bool
	
	length(numberstring) < 2 && return false
	all(x -> isnumeric(x) || isspace(x),numberstring) || return false
	prep = parse.(Int,collect(replace(numberstring," "=>"")))
	(iszero(prep) && count(x->x==0,prep) <= 1) && return false
	sum(begin
		setindex!(prep,
		[(i*=2; i>9 ? i-9 : i) for i in prep[end-1:-2:1]],
		length(prep)-1:-2:1)
	    	end
		) % 10 == 0
end
