function nicomachus(number::Int)::AbstractArray

	number < 1 && throw(DomainError("Number needs to be >= 1"))
	
	[c for c in 1:number-1 if number % c == 0]

end

function isperfect(number::Int)::Bool

	sum(nicomachus(number)) == number

end

function isabundant(number::Int)::Bool

	sum(nicomachus(number)) > number

end

function isdeficient(number::Int)::Bool

	divisors = nicomachus(number)
	
	!any(x->x!=1,divisors) || sum(divisors) < number

end
#
#=
# Alternative solution
# Full recursive version
# (Unfortunately runs into a StackOverFlowError for large numbers (as probably to be expected))
#
function nicomachus(number::Int,
		candidate::Int=1,
                divisors::AbstractArray=[])::Int

        candidate == number && return sum(divisors)

        number % candidate == 0 && (append!(divisors,candidate))

        nicomachus(number,candidate+1,divisors)

end
#
=#
