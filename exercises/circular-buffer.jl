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

# Traits

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

# -----------------------------------------------------------------------
# helper function for `getindex()` & `setindex()`

_get_circ_idx(x::Int, i::Int, max::Int) = (((x - 1) + (i - 1)) % max) + 1

# entry point for `getindex()`: tests whether circular buffer is empty before getting anything

function Base.getindex(cb::CircularBuffer,
                       i::Union{Int,AbstractRange{Int},Vector{Int}})
    getindex(FillingLevel(cb, Val{:empty}), cb, i)
end

Base.getindex(::Empty{true}, cb::CircularBuffer, _) = throw(BoundsError(cb, "Buffer is empty"))

# if circular buffer is not empty, checks whether requested index is within range of circular buffer capacity

function Base.getindex(::Empty{false}, cb::CircularBuffer,
                       i::Union{Int,AbstractRange,Vector})
    getindex(WithinBounds(cb, Val{:length}, i...), cb, i)
end

Base.getindex(::WithinLength{false}, cb::CircularBuffer, _) = throw(BoundsError(cb,"Index exceeds set bounds of buffer"))

function Base.getindex(::WithinLength{true}, cb::CircularBuffer,
                       i::Union{Int,AbstractRange,Vector})
    _getindex(cb, i)
end

# default `getindex()` method for circular buffers

function _getindex(cb::CircularBuffer, element::Int;
                   _get_idx::Function=_get_circ_idx)
    getindex(cb.queue, _get_idx(cb.head, element, capacity(cb)))
end

function _getindex(cb::CircularBuffer,
                   elements::Union{AbstractRange{Int},Vector{Int}};
                   _get_idx::Function=_get_circ_idx)
    (capacity(cb), elements) |> 
    _i -> map(e -> _get_idx(cb.head, e, _i[1]), _i[2]) |> 
    _e -> getindex(cb.queue, _e)
end

# =====================================================================================
# entry point for `setindex()`: checks whether given index is within capacity of circular buffer
# for `setindex()` `overwrite` is always `true`
# adheres to defaut behavior: e.g. if at least some indices remain `#undef` `iterate()` will return an error

function Base.setindex!(cb::CircularBuffer{T}, value::T, key::Int) where {T}
    setindex!(WithinBounds(cb, Val{:capacity}, key), cb, value, key)
end

function Base.setindex!(cb::CircularBuffer{T},
                        values::Vector{T},
                        keys::Vector{Int}) where {T}
    setindex!(WithinBounds(cb, Val{:capacity}, keys...), cb, values, keys)
end

Base.setindex!(::WithinCapacity{false}, cb::CircularBuffer, _, _) = throw(BoundsError(cb, "At leat one index exceeds the bounds of this buffer"))

function Base.setindex!(::WithinCapacity{true}, 
                        cb::CircularBuffer{T},
                        values::Union{T, Vector{T}},
                        keys::Union{Int, Vector{Int}}) where {T}
    _setindex!(cb, values, keys)
end    

# default `setindex()` method for circular buffers

function _setindex!(cb::CircularBuffer{T}, value::T, key::Int;
                    _getidx::Function=_get_circ_idx) where {T}
    _key = _getidx(cb.head, key, capacity(cb))
    key > length(cb) && (cb.tail = _key)
    setindex!(cb.queue, value, _key)
end

function _setindex!(cb::CircularBuffer{T},
                    values::Vector{T},
                    keys::Vector{Int};
                    _getidx::Function=_get_circ_idx) where {T}
    _capacity = capacity(cb)
    _maxkey = maximum(keys)
    _keys = map(k -> _getidx(cb.head, k, _capacity), keys)
    _maxkey > length(cb) && (cb.tail = _keys[_maxkey]) 
    setindex!(cb.queue, values, _keys)
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

Base.pop!(::Empty{true}, cb::CircularBuffer) = throw(BoundsError(cb,"Can not get anything from buffer; buffer is empty"))

Base.pop!(::Empty{false}, cb::CircularBuffer) = _pop!(cb)

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

Base.popfirst!(::Empty{true}, cb::CircularBuffer) = throw(BoundsError(cb,"Can not get anything from buffer; buffer is empty"))

Base.popfirst!(::Empty{false}, cb::CircularBuffer) = _popfirst!(cb)

function _popfirst!(cb::CircularBuffer;
                    _getidx::Function=_next_circ_idx)
    f = first(cb)
    length(cb) == 1 ? empty!(cb) : 
        (cb.head = _getidx(cb.head, capacity(cb)))
    return f
end

# --------------------------------------------------------------------------------------

# branching helper function for `push!()`, `pushfirst()` and `append!()`

function _insert_cb(cb::CircularBuffer, items::Tuple;
                    overwrite=false, fct::Function)
    _insert_cb(Recycle(overwrite), cb, items; fct=fct)
end

function _insert_cb(::Overwrite{true}, cb::CircularBuffer,
                    items::Tuple; fct::Function)
    fct(cb, items)
end

function _insert_cb(::Overwrite{false}, cb::CircularBuffer,
                    items::Tuple; fct::Function)
    _insert_cb(FillingLevel(cb, Val{:full}), cb, items; fct=fct)
end

function _insert_cb(::Full{true}, cb::CircularBuffer, _i; __...)
    throw(BoundsError(cb, "Sorry buffer full"))
end

function _insert_cb(::Full{false}, cb::CircularBuffer,
                    items::Tuple; fct::Function)
    fct(cb, items) 
end

# entry point for `push!()` method

function Base.push!(cb::CircularBuffer{T}, items::T...;
                    overwrite=false) where {T}
    _insert_cb(cb, items; overwrite=overwrite, fct = _push!)
end

# default `push!()` method for circular buffers

function _push!(cb::CircularBuffer{T}, items::Tuple{T,Vararg{T}}) where {T}
    _push!(cb, collect(items))
end

function _push!(cb::CircularBuffer{T}, items::Vector{T};
                _nxtidx::Function=_next_circ_idx) where {T}
    isempty(items) && return cb
    _capacity = capacity(cb)
    i = popfirst!(items)
    next_tail = _nxtidx(cb.tail, _capacity)
    next_tail == cb.head && cb.tail > 0 && (cb.head = _nxtidx(cb.head, _capacity))
    cb.tail = next_tail
    cb.queue[cb.tail] = i
    _push!(cb, items)    
end

# entry point for `pushfirst!()` method

function Base.pushfirst!(cb::CircularBuffer{T}, items::T...;
                         overwrite=false) where {T}
    _insert_cb(cb, items; overwrite=overwrite, fct = _pushfirst!)
end

# default `pushfirst!()` method for circular buffers

function _pushfirst!(cb::CircularBuffer{T}, items::Tuple{T,Vararg{T}};
                     _prvidx::Function=_get_prev_idx) where {T}
    function _insert(v::Vector, _cb::CircularBuffer=cb, 
                     _c::Int=_capacity; _pi=_prvidx)
        isempty(v) && return cb
        cb.tail > 0 ? 
            ((cb.head = _pi(cb.head, _c));
            (cb.head == cb.tail && (cb.tail = _pi(cb.tail, _c)))) : 
            (cb.tail = 1)
        i = popfirst!(v)
        cb.queue[cb.head] = i
        _insert(v)
    end
    _capacity = capacity(cb)
    _length = length(items)
    rest = div(_length-_capacity, _capacity)*_capacity
    tmp = items[begin+rest:end]
    
    return _insert(collect(tmp)) 
end

# entry point for 'append!()` method

function Base.append!(cb::CircularBuffer{T}, collections::T...;
                      overwrite=false) where {T}
    _insert_cb(cb, collections; overwrite=overwrite, fct = _append!)
end

function Base.append!(cb::CircularBuffer{T}, rng::AbstractRange{T};
                      overwrite=false) where {T}
    _insert_cb(cb, Tuple(rng); overwrite=overwrite, fct = _append!)
end

function _append!(cb::CircularBuffer{T},
                  collections::Tuple{T,Vararg{T}};
                  _p=_push!) where {T}
    tmp = collect(Iterators.flatten(collections))
    _p(cb, tmp)
end
