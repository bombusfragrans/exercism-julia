using Dates

function add_gigasecond(date::DateTime,
		addseconds::Second=Second(1e9)):DateTime

	date + addseconds
end
