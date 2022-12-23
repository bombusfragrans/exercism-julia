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

abstract type FillingLevel end

struct Empty{T} <: FillingLevel end

struct Full{T} <: FillingLevel end

FillingLevel(cb::CircularBuffer,::Type{Val{:empty}}) = Empty{isempty(cb)}()

FillingLevel(cb::CircularBuffer,::Type{Val{:full}}) = Full{isfull(cb)}()

abstract type Recycle end

struct Overwrite{T} <: Recycle end

Recycle(b::Bool) = Overwrite{b}()

abstract type WithinBounds end

struct WithinCapacity{T} <: WithinBounds end

struct WithinLength{T} <: WithinBounds end

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
# TODO: test passed to here
# -----------------------------------------------------------------------
# helper function for `getindex()` & `setindex()`

_get_circ_idx(x::Int, i::Int, max::Int) = (((x - 1) + (i - 1)) % max) + 1

# entry point for `getindex()`: tests whether circular buffer is empty before getting anything

function Base.getindex(cb::CircularBuffer, i::Int...)  # TODO: test from here ...
    getindex(FillingLevel(cb, Val{:empty}), cb, i)
end

Base.getindex(::Type{Empty{true}}, cb::CircularBuffer, _...) = throw(BoundsError(cb, "Buffer is empty"))

# if circular buffer is not empty, checks whether requested index is within range of circular buffer capacity

function Base.getindex(::Type{Empty{false}}, cb::CircularBuffer, i::Int...)
    getindex(WithinBounds(cb, Val{:length}, i), cb, i...)
end

Base.getindex(::Type{WithinLength{false}}, cb::CircularBuffer, _...) = throw(BoundsError(varargs[1],"Index exceeds set bounds of buffer"))

Base.getindex(::Type{WithinLength{true}}, cb::CircularBuffer, i::Int...) = _getindex(cb, i...)

# default `getindex()` method for circular buffers

function _getindex(cb::CircularBuffer, elements::Int...;
                   _get_idx::Function=_get_circ_idx)
    _capacity = capacity(cb)
    _elements = map(e -> _get_idx(cb.head, e, _capacity, elements))
    getindex(cb.queue, _elements...) 
end

# =====================================================================================
# entry point for `setindex()`: checks whether given index is within capacity of circular buffer
# for `setindex()` `overwrite` is always `true`
# adheres to defaut behavior: e.g. if at least some indices remain `#undef` `iterate()` will return an error

function Base.setindex!(cb::CircularBuffer,
                        value::eltype(cb), key::Int...)
    setindex!(WithinBounds(cb, Val{:capacity}, key...), cb, value, key...)
end

Base.setindex!(::Type{WithinCapacity{false}}, varargs...) = throw(BoundsError(varargs[1], "At leat one index exceeds the bounds of this buffer"))

function Base.setindex!(::Type{WithinCapacity{true}}, varargs...) = _setindex!(varargs...)

# default `setindex()` method for circular buffers

function _setindex!(cb::CircularBuffer,
                    value::eltype(cb), key::Int...;
                    _getidx::Function=_get_circ_idx)
    _maxkey = maximum(key)
    _key = map(k -> _getidx(cb.head, k, capacity(cb), key)
    _maxkey > length(cb) && (cb.tail = _key[_maxkey]) 
    setindex!(cb.queue, value, _key...)
end

############################################################################
# misc utility methods

capacity(cb::CircularBuffer) = length(cb.queue)

isfull(cb::CircularBuffer) = (length(cb) == capacity(cb))

function Base.empty!(cb::CircularBuffer)
    cb.head, cb.tail = 1, 0
    return cb
end

Base.convert(::Type{Array}, cb::CircularBuffer{T}) where {T} = T[x for x in collect(cb)] # alternative: `T.(collect(cb))`

############################################################################
# helper function for `pop!()` and `pushfirst()`

_get_prev_idx(x::Int, max::Int) = (((x - 1) + (max - 1)) % max) + 1

# entry point for `pop!()`: checks whether buffer is empty befor returning anything

Base.pop!(cb::CircularBuffer) = pop!(FillingLevel(cb, Val{:empty}), cb)

Base.pop!(::Type{Empty{true}}, cb::CircularBuffer) = throw(BoundsError(cb,"Can not get anything from buffer; buffer is empty"))

Base.pop!(::Type{Empty{false}}), cb::CircularBuffer) = _pop!(cb)

# default `pop!()` method for cirular buffers

function _pop!(cb::CircularBuffer;
              _getidx::Function=_get_prev_idx)
    l = last(cb)
    length(cb) == 1 ?  empty!(cb) :
        (cb.tail = _getidx(cb.tail, capacity(cb)))
    return l
end

# helper function for `popfirst!()` and `push()`

_next_circ_idx(x::Int, max::Int) = (x % max) + 1

# entrypoint for `popfirst!()`: checks whether buffer is not empty before getting anything

Base.popfirst!(cb::CircularBuffer) = popfirst!(FillingLevel(cb, Val{:empty}), cb)

Base.popfirst!(::Type{Empty{true}}, cb::CircularBuffer) = throw(BoundsError(cb,"Can not get anything from buffer; buffer is empty"))

Base.popfirst!(::Type{Empty{false}}, cb::CircularBuffer) = _popfirst!(cb)

function _popfirst!(cb::CircularBuffer;
                    _getidx::Function=_next_circ_idx)
    f = first(cb)
    length(cb) == 1 ? empty!(cb) : 
        (cb.head = _getidx(cb.head, capacity(cb)))
    return f
end

# --------------------------------------------------------------------------------------

# branching helper function for `push!()`, `pushfirst()` and `append!()`

_insert_cb(cb::CircularBuffer, items...; overwrite=false, fct!::Function) = _insert_cb(Recycle(overwrite), cb, items...; fct!)

_insert_cb(::Type{Overwrite{true}}, cb::CircularBuffer, items...; _fct!::Function) = _fct!(cb, items)

_insert_cb(::Type{Overwrite{false}}, cb::CircularBuffer, items...; _fct!::Function) = _insert_cb(FillingLevel(cb, Val{:empty}), cb, items...; _fct!)

_insert_cb(::Type{Full{true}}, cb, _; _) = throw(BoundsError(cb, "Sorry buffer full"))

_insert_cb(::Type{Full{false}}, cb, items...; _fct!) = _fct!(cb, items...) 


# entry point for `push!()` method

Base.push!(cb::CircularBuffer, items::eltype(cb); overwrite=false) = _insert_cb(cb, items...; overwirte=overwrite, fct!=_push!)

# default `push!()` method for circular buffers

function _push!(cb::CircularBuffer, items::eltype(cb)...;
                _nxtidx::Function=_next_circ_idx)
    isempty(items) && return cb
    _capacity = capacity(cb)
    _items = collect(items)
    i = popfirst!(_items)
    next_tail = _nxtidx(cb.tail, _capacity)
    next_tail == cb.head && cb.tail > 0 && (cb.head = _nxtidx(cb.head, _capacity))
    cb.tail = next_tail
    cb.queue[cb.tail] = i
    _push!(cb, _items)    
end

# entry point for `pushfirst!()` method

Base.pushfirst!(cb::CircularBuffer, value::eltype(cb); overwrite=false) = _insert_cb(cb, items...; overwrite=overwrite, fct!=_pushfirst!)

# default `pushfirst!()` method for circular buffers

function _pushfirst!(cb::CircularBuffer, items::eltype(cb)...;
                     _prvidx::Function=)
    function _insert(v::Vector, _cb::CircularBuffer=cb, 
                     _c::Int=_capacity; _pi=_prvidx)
        isempty(v) && return cb
        cb.tail > 0 ? 
            ((cb.head = _pi(cb.head, _c));
            (cb.head == cb.tail && (cb.tail = _pi(cb.tail, _c))) : 
            (cb.tail = 1)
        i = popfirst!(v)
        cb.queue[cb.head] = i
        _insert(v)
    end
    _capacity = capacity(cb)
    _length = length(value)
    rest = div(_length-_capacity, _capacity)*_capacity
    tmp = items[begin+rest:end]
    
    return _insert(tmp) 
end

# entry point for 'append!()` method

Base.append!(cb, collections::etype(cb)...; overwrite=false) = _insert_cb(cb, collections...; overwrite=overwrite, fct!=_append!)

function _append!(cb::CircularBuffer,
                  collections::eltype(cb)...;
                  _p!=_push!)
    tmp = collect(Iterators.flatten(collections))
    _p!(cb, tmp...)
end

# TODO: ...to here
