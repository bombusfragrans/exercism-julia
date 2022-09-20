function bob(stimulus)

	stripped = strip(stimulus)

	isempty(stripped) && return "Fine. Be that way!"

	isquestion = endswith(stripped,'?')

	isyell = any(isletter,stripped) && !any(islowercase,stripped)

	isquestion && !isyell && return "Sure."

	!isquestion && isyell && return "Whoa, chill out!"
	
	isquestion && isyell && return "Calm down, I know what I'm doing!"

	"Whatever."
end
