"""Calculate the number of grains on square `square`."""
function on_square(square::Int)::BigInt
	
	(square <= 0 || square > 64) && begin
		throw(DomainError(
			ifelse(square <= 0, 
			"square needs to be > 0",
			"square needs to be <= 64"))) 
		end
	square == 1 && return BigInt(1)
	on_square(square-1)*2
end

"""Calculate the total number of grains after square `square`."""
function total_after(square::Int)::BigInt
	
	square == 1 && return BigInt(1)
	on_square(square) + total_after(square-1)
end
