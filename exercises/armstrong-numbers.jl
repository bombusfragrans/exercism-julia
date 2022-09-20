
function isarmstrong(number::Int)::Bool
	
	d = digits(number,base=10)
	number == sum(d .^ length(d))
end
