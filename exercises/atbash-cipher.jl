function encode(input::AbstractString)::AbstractString
	
	d = Dict(k => v for (k,v) in zip('a':'z', reverse('a':'z')))
	s = lowercase(input)
	a = [isletter(x) ? d[x] : x for x in s if !ispunct(x) && !isspace(x)]
	join(join.(Iterators.partition(a,5)), " ")
end

function decode(input::AbstractString)::AbstractString
	
	d = Dict(k => v for (k,v) in zip(reverse('a':'z'),'a':'z'))
	join([isletter(x) ? d[x] : x for x in input if !ispunct(x) && !isspace(x)])
	
end

