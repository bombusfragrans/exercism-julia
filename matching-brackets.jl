const MATCHING_BRACKETS = Dict(
			       ')' => '(',
			       ']' => '[',
			       '}' => '{'
			       )

function matching_brackets(str::AbstractString,
			   bks::Dict=MATCHING_BRACKETS)::Bool

	stk = []

	res = str == "" ? true : false

	for c in str 	
		
		c in ['(', '[', '{'] && (append!(stk,c); continue)

		c in [')', ']', '}'] || continue 
			
		isempty(stk) && (res = false; break)

		res = pop!(stk) == bks[c] ? true : false

		res == false && break

	end

	!isempty(stk) && (res = false)

	return res

end
