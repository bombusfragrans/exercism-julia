function is_equilateral(sides)

	any(s->s==0,sides) && return false

	sides[1] == sides[2] == sides[3]

end

function is_isosceles(sides)

	(any(s->s==0,sides) || !(2*maximum(sides) < sum(sides))) && return false

	any([i==j for (i,j) in zip(sides,circshift(sides,-1))])

end

function is_scalene(sides)

	(any(s->s==0,sides) || !(2*maximum(sides) < sum(sides))) && return false

	!(any([i==j for (i,j) in zip(sides,circshift(sides,-1))]))

end
