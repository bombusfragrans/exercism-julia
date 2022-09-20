# Change any of the following NamedTuple values to true to 
# enable testing different bonus tasks
tested_benus_tasks = (rev = true, by = true, lt = true, multiple_matches = true)

function binarysearch(haystack::AbstractArray,
		needle::Number;
		rev::Bool=false,
		by::Function=identity,
		lt::Function=ifelse(rev,>,<),
		multiple_matches::Bool=true
		)::UnitRange

	next(v,x,m,d) = begin
		z = d(m,1); z >= 1 && z <= length(v) && v[z] == x
		end ? 
		next(v,x,z,d) : m 

	isempty(haystack) && return 1:0
	
	haystack = Int.(by.(haystack))
	needle = Int(by(needle))

	mid = floor(Int,((length(haystack)+1)/2))
	
	(current = haystack[mid]; current == needle) && begin 
		multiple_matches ? 
		(return next(haystack,needle,mid,-):next(haystack,needle,mid,+)) : 
		return mid:mid
	end
	
	if lt(needle,current)	# default <
		length(haystack) == 1 && return current:current-1
		binarysearch((@view haystack[begin:mid-1]), needle;
			     rev=rev,by=by,lt=lt,multiple_matches=multiple_matches)
	else
		length(haystack) == 1 && return current+1:current
		mid .+ binarysearch((@view haystack[mid+1:end]), needle;
				    rev=rev,by=by,lt=lt,multiple_matches=multiple_matches)
	end
end

#=
# Alternative solution:

function binarysearch(<Up>haystack::AbstractArray,
                needle::Number;
                rev::Bool=false,
                by::Function=identity,
                lt::Function=ifelse(rev,>,<),
                #multiple_matches::Bool=true
                )::UnitRange

	findslot(v,x) = (next = findlast(z->z==x-1,v); !isnothing(next)) ? 
		next : findslot(v,x-1)

	isempty(haystack) && return 1:0

	haystack = Int.(by.(haystack))
        needle = Int(by(needle))

	(found = findall(z->z==needle,haystack); !isempty(found)) ? 
		(return found[begin]:found[end]) : begin
			(lt(needle,haystack[begin])) && return 1:0
			(lt(haystack[end],needle)) && (max = length(haystack); 
				return max+1:max)
			slot = findslot(haystack,needle)
			return slot:slot-1
		end
end
=#
