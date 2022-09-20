function triangle(n)

	n < 0 && throw(DomainError(n, "number of rows has to be larger than 0"))
	n <= 5 && return map(x->digits(11^x),0:n-1)	# returns [] if n=0 & [1] if n=1
	vcat(triangle(5),
	     	map(6:n) do z	
			vcat([1],Int.(accumulate(1:z-1,init=1) do x,y
				x * ((z-1) - y + 1) / y 
			end))
		end)
end

#=
# Alternative solution (recursive)

function triangle(n::Int)

	n < 0 && throw(DomainError(n, "number of rows has to be larger than 0"))

	n==0 && return []

	n==1 && return [[1]]

	t=triangle(n-1)

	push!(t, [t[end];0]+[0;t[end]])

end
=#
