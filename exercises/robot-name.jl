using Random

const NAMES = Set{String}()

mutable struct Robot
	name::String
end

Robot() = Robot(setname())

function setname(history::Set{String}=NAMES)::String
	
	name = randstring('A':'Z',2) * randstring('1':'9',3)

	name in history ? setname(history) : (push!(history,name); return name)

end

function reset!(instance::Robot)
	instance.name = setname()
end

function name(instance::Robot)
	instance.name
end
