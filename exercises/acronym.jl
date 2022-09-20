function acronym(phrase)
	
	splitted = split(phrase,r"[ _-]+")
	uppercase(join(first.(splitted)))
end
