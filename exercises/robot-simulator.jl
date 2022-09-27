# required imports

import Base: ==

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

# Point(x::Int, y::Int) dispatched to default constructor

Robot(t::Tuple{Int,Int},H::Type{<:Heading})::Robot = Robot(Point(t...),H)	

# Robot(p::Point,H::HEADING) dispatched to default constructor

#------------------
# methods / traits

position(R::Robot)::Point = R.position

heading(R::Robot)::Type{<:Heading} = R.heading 

# just forthe record: could have been done by a macro, but would be less explicit and thus more challenging to read

_turn_right(::Type{NORTH}) = EAST

_turn_right(::Type{EAST}) = SOUTH

_turn_right(::Type{SOUTH}) = WEST

_turn_right(::Type{WEST}) = NORTH

function turn_right!(R::Robot)
    R.heading = _turn_right(heading(R))
    return R
end

_turn_left(::Type{NORTH}) = WEST

_turn_left(::Type{WEST}) = SOUTH

_turn_left(::Type{SOUTH}) = EAST

_turn_left(::Type{EAST}) = NORTH

function turn_left!(R::Robot)
    R.heading = _turn_left(heading(R))
    return R
end

#=
# optional: alternative approach to `turn_right` & `turn_left`
# just for the record
const DIRECTIONS = (NORTH,EAST,SOUTH,WEST)
# turn_right: return value of next index
# turn_left: return value of previous index
# challenge: turn_left(NORTH) & turn_right(WEST)
# ???more julianic/julianesc using dispatch???
=#

_advance!(::Type{NORTH}, R::Robot) = R.position.y += 1	

_advance!(::Type{EAST}, R::Robot) = R.position.x += 1

_advance!(::Type{SOUTH}, R::Robot) = R.position.y -= 1

_advance!(::Type{WEST}, R::Robot) = R.position.x -= 1

function advance!(R::Robot)
    _advance!(heading(R),R)
    return R
end

# just a reminder (for the record): setting `R.position.x` & `R.position.y` could be done with proper setter functions (using the delegate pattern)

_move!(::Type{Val{:A}},R::Robot) = advance!(R)

_move!(::Type{Val{:R}},R::Robot) = turn_right!(R)

_move!(::Type{Val{:L}},R::Robot) = turn_left!(R) 

function move!(R::Robot,c::Char)
    _move!(Val{Symbol(c)},R)
    return R
end  

function move!(R::Robot,v::Vector{Char})
    foreach(c -> move!(R,c), v)
    return R
end

function move!(R::Robot,s::String)
    move!(R,collect(s))
    return R
end

#----------------------
# 'overloaded' methods

==(a::T,b::T) where {T<:Point} = a.x == b.x && a.y == b.y

==(a::T,b::T) where {T<:Robot} = position(a) == position(b) && heading(a) == heading(b)
