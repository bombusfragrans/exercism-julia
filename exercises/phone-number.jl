function clean(phone_number)
	
	number = filter(isnumeric,phone_number)
	(length(number) == 11 && first(number) == '1') && (number = number[2:end])
	(length(number) == 10 && first(number) >= '2' && number[4] >= '2') && return number
	throw(ArgumentError("phone number invalid"))

end
#
#=
# Alternative solution
#
function clean(phone_number)
	x = match(r"^\D*\+*1?\D*([2-9]\d{2})\D*([2-9]\d{2})\D*(\d{4})\D*$", phone_number)
	x == nothing ? throw(ArgumentError(phone_number)) : join(x.captures)
end
=#
