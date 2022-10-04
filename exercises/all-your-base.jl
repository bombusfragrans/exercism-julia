# Implement number base conversion

function all_your_base(digits::Vector,
                       base_in::Int,
                       base_out::Int
                      )::Vector{Int}

    ERR(x,m) = throw(DomainError(x,m))
    
    (base_in <= 1 || base_out <= 1) && 
        ERR((base_in, base_out),"base_in & base_out have to be larger than 1")
    
    (isempty(digits) || !any(d -> d != 0, digits)) && return [0]
    
    any(d -> d < 0 || d >= base_in, digits) && 
        ERR(digits, "all digits have to be positive and smaller than their base")

    convertBase(digits, base_in, base_out)

end

# ================
# helper functions

function fromDigits(digits::Vector{Int},
		    base_in::Int,
		    num::Int=0)::Int
	
	isempty(digits) && return num

	new_num = base_in * num + popfirst!(digits)

	fromDigits(digits,base_in, new_num)

end

function toDigits(num::Int,
                  base_out::Int,
                  digits::Vector{Int}=Int[]
                 )::Vector{Int}

    num == 0 && return digits

    pushfirst!(digits, num % base_out)

    toDigits(fld(num, base_out), base_out, digits)

end

function convertBase(digits::Vector{Int},
                     base_in,
                     base_out;
                     fd::Function=fromDigits,
                     td::Function=toDigits)::Vector{Int}

    fd(digits, base_in) |> d -> td(d, base_out)

end
