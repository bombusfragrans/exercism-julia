#=

    CircularBuffer{T}(capacity::Int) <: AbstractVector{T}

Creates an intially empty CircularBuffer of fixed capacity (which can be overwritten)
containing elements of type `T`

# simplified compared to [CircularBuffer.jl](https://github.com/JuliaCollections/DataStructures.jl/blob/master/src/circular_buffer.jl)
=#

mutable struct CircularBuffer{T} <: AbstractVector{T}

    head::Int
    tail::Int
    queue::Vector{T}

    function CircularBuffer{T}(capacity::Integer) where {T}
        new{T}(1, 0, Vector{T}(undef, capacity))
    end
end

abstract type FillingLevel end  # TODO: test from here ...

struct Empty{T <: Bool} <: FillingLevel end

struct Full{T <: Bool} <: FillingLevel end

FillingLevel(cb::CircularBuffer,::Type{Val{:empty}}) = Empty{isempty(cb)}()

FillingLevel(cb::CircularBuffer,::Type{Val{:full}}) = Full{isfull(cb)}()

abstract type Recycle end

struct Overwrite{T <: Bool} <: Recycle end

Recycle(::Type{Val{T}} where {T <: Bool}) = Overwrite{T}()  # TODO: ... to here

abstract type WithinBounds end

struct WithinCapacity{T <: Bool} <: WithinBounds end

struct WithinLength{T <: Bool} <: WithinBounds end

function WithinBounds(cb::CircularBuffer, ::Type{Val{:capacity}}, key::Int...)
    _capacity = capacity(cb)
    WithinCapacity{all(k -> 1 <= k <= _capacity, key)}()
end

function WithinBounds(cb::CircularBuffer, ::Type{Val{:length}}, key::Int...)
    _length = length(cb)
    WithinLength{all(k -> 1 <= k <= _length, key)}()
end

#=
########################################################
interface methods
needed to "inherit"
- `[i]` (indexing & slicing)
- `last()`/`first()`
- `length()`  # derived from `size()`
- `==`
- `isempty()`
- `eltype()`/`typeof()`
- `iterate()`
from `AbstractVector`
=#

#=
helper function for `size()`
`size()` enables `length()` & `isempty()` as
`length(t::AbstractArray) = (@inline; prod(size(t)))`
`isempty(a::AbstractArray) = (length(a) == 0)`)
=#

function _get_no_elem(cb::CircularBuffer)
    cb.tail == 0 && return 0
    c = capacity(cb)
    (((c + cb.tail) - cb.head) % c) + 1
end

Base.size(cb::CircularBuffer; _gne::Function=_get_no_elem) = (_gne(cb),)  # also defines stop length for `iterate()`, but not for `getindex()`

##########################################################################
# helper function for `getindex()` & `setindex()`

_get_circ_idx(x::Int, i::Int, max::Int) = (((x - 1) + (i - 1)) % max) + 1

# entry point for `getindex()`: tests whether circular buffer is empty before getting anything

function Base.getindex(cb::CircularBuffer, i::Int)  # TODO: test from here ...
    getindex(FillingLevel(cb, Val{:empty}), cb, i)
end

Base.getindex(::Type{Empty{true}}, varargs...) = throw(BoundsError(varargs[1],"Buffer is empty"))

# if circular buffer is not empty, checks whether requested index is within range of circular buffer capacity

function Base.getindex(::Type{Empty{false}}, varargs...)
    cb, i = varargs
    getindex(WithinBounds(cb, Val{:length}, i), varargs...)
end

Base.getindex(::Type{WithinLength{false}}, varargs...) = throw(BoundsError(varargs[1],"Index exceeds set bounds of buffer"))

Base.getindex(::Type{WithinLength{true}}, varargs...) = _getindex(varargs...)

# default `getindex()` method for circular buffers

function _getindex(cb::CircularBuffer, i::Int;
                   _get_idx::Function=_get_circ_idx)
    getindex(cb.queue, _get_idx(cb.head, i, capacity(cb)))
end

# -----------------------------------------------------------------------------
# entry point for `setindex()`: checks whether given index is within capacity of circular buffer
# for `setindex()` `overwrite` is always `true`
# adheres to defaut behavior: e.g. if at least some indices remain `#undef` `iterate()` will return an error

function Base.setindex!(cb::CircularBuffer,
                        value, key::Int...) # jfyi: `value::eltype(cb)` possible, but not necessary
    setindex!(WithinBounds(cb, Val{:capacity}, key...), cb, value, key...)
end

Base.setindex!(::Type{WithinCapacity{false}}, varargs...) = throw(BoundsError(varargs[1], "At leat one index exceeds the bounds of this buffer"))

function Base.setindex!(::Type{WithinCapacity{true}}, varargs...) = _setindex!(varargs...)

# default `setindex()` method for circular buffers

function _setindex!(cb::CircularBuffer,
                        value, key::Int...;
                        _getidx::Function=_get_circ_idx)
    capacity(cb) |>
    _capacity -> map(k -> _getidx(cb.head, k, _capacity, key) |>
    (_key -> setindex!(cb.queue, value, _key...); cb.tail = _key[maximum(key)])

end

############################################################################
# other utility methods

capacity(cb::CircularBuffer) = length(cb.queue)

isfull(cb::CircularBuffer) = (length(cb) == capacity(cb))

function Base.empty!(cb::CircularBuffer)
    cb.head, cb.tail = 1, 0
    return cb
end

# add convert here

############################################################################
# helper function for `pop!()`

_get_prev_idx(x::Int, max::Int) = (((x - 1) + (max - 1)) % max) + 1

# entry point for `pop!()`: checks whether buffer is empty befor returning anything

Base.pop!(cb::CircularBuffer) = pop!(FillingLevel(cb, Val{:empty}), cb)

Base.pop!(::Type{Empty{true}}, cb::CircularBuffer) = throw(BoundsError(cb,"Can not get anything from buffer; buffer is empty"))

Base.pop!(::Type{Empty{false}}), cb::CircularBuffer) = _pop!(cb)

# default `pop!()` method for cirular buffers

function _pop!(cb::CircularBuffer;
              _getidx::Function=_get_prev_idx)
    l = last(cb)
    cb.tail = _getidx(cb.tail, capacity(cb))
    return l
end

# helper function for `popfirst!()`

_next_circ_idx(x::Int, max::Int) = (x % max) + 1

# entrypoint for `popfirst!()`: checks whether buffr is not empty before getting anything

Base.popfirst!(cb::CircularBuffer) = popfirst!(FillingLevel(cb, Val{:empty}), cb)

Base.popfirst!(::Type{Empty{true}}, cb::CircularBuffer) = throw(BoundsError(cb,"Can not get anything from buffer; buffer is empty"))

Base.popfirst!(::Type{Empty{false}}), cb::CircularBuffer) = _popfirst!(cb)

function _popfirst!(cb::CircularBuffer;
                    _getidx::Function=_next_circ_idx)
    f = first(cb)
    cb.head = _getidx(cb.head, capacity(cb))
    return f
end

# --------------------------------------------------------------------------------------

# parameter: overwrite ...

# entry point for `push!()` method

Base.push!(cb::CircularBuffer, i::Int; overwrite=false) = push!(Recycle(Val{overwrite}), cb, i)

Base.push!(::Type{Overwrite{false}}, cb::CircularBuffer, i::Int) = push!(FillingLevel(cb, Val{:full}), cb, i)

Base.push!(::Type{Full{true}}, cb::CircularBuffer, _) = throw(BoundsError(cb,"Can not add value because buffer is full"))

Base.push!(::Type{Full{false}}, cb::CircularBuffer, i::Int) = _push!(cb, i)

Base.push!(::Type{Overwrite{true}}), cb::CircularBuffer, i::Int) = _push!(cb, i)

# default `push!()` method for circular buffers

function _push! end

# entry point for `pushfirst!()` method

Base.pushfirst!(cb::CircularBuffer, i::Int; overwrite=false) = pushfirst!(Recycle(Val{overwrite}), cb, i)

Base.pushfirst!(::Type{Overwrite{false}}, cb::CircularBuffer, i::Int) = pushfirst!(FillingLevel(cb, Val{:full}), cb, i)

Base.pushfirst!(::Type{Full{true}}, cb::CircularBuffer, _) = throw(BoundsError(cb,"Can not add value because buffer is full"))

Base.pushfirst!(::Type{Full{false}}, cb::CircularBuffer, i::Int) = _pushfirst!(cb, i)

Base.pushfirst!(::Type{Overwrite{true}}), cb::CircularBuffer, i::Int) = _pushfirst!(cb, i)

# default `pushfirst!()` method for circular buffers

function _pushfirst! end

function _append! end

# TODO: ...to here

# partially tested until here
############################################################################

function convert(::Type{T}, cb::CircularBuffer) where {T <: AbstractArray}
    # see example in circularbuffer.jl using a list comprehension (as iterate works)
    # ist with other utility functions
    map(i -> getindex(cb, i), 1:cb.capacity) |> x -> convert(T, x)

end
