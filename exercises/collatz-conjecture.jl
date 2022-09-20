function collatz_steps(n)

	cs(x,c=[]) = begin	
		x>1 && (isodd(x) ?
				(z = 3x+1; cs(z,c)) :
				(z = x/2; cs(z,c));
				push!(c,z))
	end

	n <= 0 && throw(DomainError("n too small"))
	n == 1 && return 0
	length(cs(n))
end

#=
# Alternative approach

function collatz_steps(n;s=0)

        n > 0 || throw(DomainError("n too small"))
        n == 1 && return s
	return collatz_steps(begin
		isodd(n) ?
		3n+1 :
		n/2;
		s=(s+1)
	end)
end
=#
