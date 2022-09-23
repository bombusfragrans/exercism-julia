# structure

mutable struct Point{T <: Int}
  x::T
  y::T
end

abstract type Heading end

struct NORTH <: Heading end

struct WEST <: Heading end

struct SOUTH <: Heading end

struct EAST <: Heading end

mutable struct Robot
  position::Point
  heading::Type{<:Heading}
end

#=
# optional: alternative parametric declaration
# just for the record
mutable struct Robot{P <: Point, H <: Heading}
  position::P
  heading::Type{H}
end
=#

#--------------
# constructors

Point(t::Tuple{Int, Int}) = Point(t...)	# PASSED

# Point(x::Int, y::Int) dispatched to default constructor

Robot(t::Tuple{Int,Int},h::Heading)::Robot = Robot(Point(t),h)	# requires custom convert?

# Robot(p::Point,h::HEADING) dispatched to default constructor

#------------------
# methods / traits

position(r::Robot)::Point = r.position

heading(r::Robot)::Heading = r.heading

# just forthe record: could have been done by a macro, but would be less explicit and thus more challenging to read

turn_right!(r::Robot) = r.heading = _turn_right(r.heading)

_turn_right(::Type{NORTH}) = EAST

_turn_right(::type{EAST}) = SOUTH

_turn_right(::Type{SOUTH}) = WEST

_turn_right(::Type{WEST}) = NORTH

turn-left!(r::Robot) = r.heading = _turn_left(r.heading)

_turn_left(::Type{NORTH}) = WEST

_turn_left(::Type{WEST}) = SOUTH

_turn_left(::Type{SOUTH}) = EAST

_turn_left(::Type{EAST}) = NORTH

#=
# optional: alternative approach to `turn_right` & `turn_left`
# just for the record
const DIRECTIONS = (NORTH,EAST,SOUTH,WEST)
# turn_right: return value of next index
# turn_left: return value of previous index
# challenge: turn_left(NORTH) & turn_right(WEST)
# ???more julianic/julianesc using dispatch???
=#

advance!(r::Robot) = _advance!(r.heading,r)

_advance!(::Type{NORTH}, r::Robot) = r.position.x += 1	# TODO: recheck delegation pattern

_advance!(::Type{EAST}, r::Robot) = r.postion.y += 1

_advance!(::Type{SOUTH}, r::Robot) = r.postion.y -= 1

_advance!(::Type{WEST}, r::Robot) = r.position.x -= 1

# just a reminder (for the record): setting `r.x` & `r.y` could be done with proper setter functions which mightbe a little overkill for this case 

move!(r::Robot,s::String) = move!(r, popfirst!(s)); !isempty(s) && move!(r, s)

move!(r::Robot,c::Char) = _move!(Symbol(c),r)

_move!(::Val{:A},r::Robot) = advance!(r)

_move!(::Val{:R},r::Robot) = turn_right!(r)

_move!(::Val{:L},r::Robot) = turn_left!(r)

#----------------------
# 'overloaded' methods

popfirst!(s::String) = popfirst!(collect(s))
