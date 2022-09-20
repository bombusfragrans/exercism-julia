# Iterator version (testing iterate)
# (apparently most efficient solution)
#
function prime_factors(number::Int)::AbstractArray

	primefactors = []

	candidates = (x for x in 2:number if isodd(x) || x == 2)	# creates a generator

	candidate = iterate(candidates)	# returns a tuple (index,state)

	while candidate !== nothing && number > 1 && !(candidate[1] > number)

		idx, state = candidate

		if number % idx == 0

			append!(primefactors,idx)
			number /= idx
		
		else
			candidate = iterate(candidates,state)
		end
	end	
	
	primefactors
end
#
#=
# Alternative solutions
#
# 'Semi-recursive' version (with a loop)
# (unfortunately gets killed)
function prime_factors(number::Int)::AbstractArray

        number <= 1 && return Int[]

        for i in [2;[x for x=3:number if isodd(x)]]
                
                number % i == 0 && return pushfirst!(prime_factors(Int(number/i)), i)
                                        # append!([i], prime_factors(Int(number/i)))
        end
end
#
=#
#=
# Alternative solutions
#
# Recursive version (without any loop)
# (unfortunately causes 'StackOverflowError' for large numbers (as to be expected))
#
function prime_factors(number::Int,
                candidate::Int=2,
                primefactors::AbstractArray=[])::AbstractArray

        (candidate > number || number < 2) && return primefactors

        ((isodd(candidate) || candidate == 2) && Int(number % candidate) == 0) ?
                (append!(primefactors,candidate);
                prime_factors(Int(number/candidate),candidate,primefactors)) :
                prime_factors(number,candidate+1,primefactors)

end
#
=#
