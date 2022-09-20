const colorvalues = Dict(
			 "black" => 0,
			 "brown" => 1,
			 "red" => 2,
			 "orange" => 3,
			 "yellow" => 4,
			 "green" => 5,
			 "blue" => 6,
			 "violet" => 7,
			 "grey" => 8,
			 "white" => 9
			)

function label(colors::AbstractArray,
		colorcodes::AbstractDict=colorvalues)::AbstractString

	ohms = (colorcodes[colors[1]] * 10 + colorcodes[colors[2]]) * 
		10 ^ colorcodes[colors[3]]
	
	postfix = "ohms"

	ohms % 1000 == 0 && (ohms = Int(ohms / 1000);
			     postfix = "kilo" * postfix)

	repr(ohms) * " " * postfix

end
