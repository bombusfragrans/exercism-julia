function sieve(limit;p=[x for x in 2:limit if isodd(x) || x<3])
	
	limit <= 7 && return p
	foreach(p) do q
		setdiff!(p,[q^2+i*q for i in 0:limit*inv(q)])
	end
	return p
end
