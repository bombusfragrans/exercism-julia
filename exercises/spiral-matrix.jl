function spiral_matrix(n)
	
	n < 1 && return Matrix{Int}(undef,0,0)
	n == 1 && return reshape(Int[1], 1, 1)
    	m = (2n - 1) .+ spiral_matrix(n-1)
    	[ permutedims(1:n); rot180(m) n+1:2n-1 ]

end
