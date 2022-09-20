function findCombinations(N::Vector{Int},
			  k::Int,
			 )::Vector{Vector{Int}}

	k < 1 && return [Int[]]

	return [append!([x],z) for x in N
		for z in findCombinations(N[begin+1:end],k-1)
		if !(x in z)] |>
		x-> sort.(x) |>
		unique

end

getpool(n::Union{Int,Vector{Int}},
	m::Union{Set,Vector}=Set(1:9)
	)::Vector{Int} = sort(collect(setdiff!(m,n)))

function combinations_in_cage(
		cagesum::Int,
		cagesize::Int,
		exclude::Union{Int,Vector{Int}}=0
		)::Vector{Vector{Int}}

	cagesize == 1 && return [[cagesum]]
	cagesum == 45 && cagesize == 9 && return [[1:9...]]

	allcombi = findCombinations(
			getpool(exclude),
			cagesize)

	filter(x->sum(x)==cagesum,allcombi)

end
#
#=
# strictly for the purpose of documenting the derivation process
# non working draft
#
function findCombinations(N::Vector{Int},
			  k::Int,
			  c::Union{Vector{Int},Vector{Vector{Int}}} = Int[],
			  f::Bool=true
			 )::Vector{Vector{Int}}

     isempty(N) && return []

     function followBranch()
     
     	d = f == true ? [] : copy(c)
     	k == 0 && return d
     	append!(d,N[end])
     	findCombinations(N[begin:end-1],k-1,d,false)
     end
                                                              
     #t = followBranch(); @show t; @show k == 1 && (t)
     length(N) > 0 && (append!(c,[followBranch()]))
     findCombinations(N[begin:end-1],k,c,f)
                                                              
end
#
function findCombinations(N,k,c=[],f=true)

	isempty(N) && return c 
	
	function followBranch()
        
		d = f == true ? [] : copy(c)#; c=[]
		k == 0 && return d
		append!(d,N[end])
		findCombinations(N[begin:end-1],k-1,d,false)

	end

	length(N) > 0 && (append!(c, [collect(followBranch())]))
	findCombinations(N[begin:end-1],k,c,f)

end
=#
