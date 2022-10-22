mutable struct CircularBuffer{T} <: AbstractVector{T}

    capacity::Int
    queue::Vector{T}
    head::Int
    tail::Int
    size::Int

    function CircularBuffer{T}(capacity::Integer) where {T}

        queue = Vector{T}(undef, capacity)
        new(capacity, queue, 1, 0, 0)

    end
end

capacity(cb::CircularBuffer) = cb.capacity

Base.eltype(cb::CircularBuffer) = eltype(cb.queue)  # also take care of `eltype(typeof(cb))`

Base.length(cb::CircularBuffer{T}) = cb.size 

Base.size(cb::CircularBuffer{T} where {T}) = (length(cb), )

isfull(cb::CircularBuffer) = cb.size == cb.capacity

Base.isempty(cb::CircularBuffer) = cb.size == 0

Base.empty!(cb::CircularBuffer) = cb.head, cb.tail, cb.size = 1, 0, 0

_next_circ_idx(x::Int, max::Int) = (x % max) + 1

_get_circ_idx(x::Int, i::Int, max::Int) = (((x - 1) + (i - 1)) % max) + 1

_get_prev_idx(x::Int, max::Int) = (((x - 1) + (max - 1)) % max) + 1 

function Base.getindex(cb::CircularBuffer{T} where {T}, i::Int;
                       get_idx::Function=_get_circ_idx)

    getindex(cb.queue, get_idx(cb.head, i, cb.capacity))

end

function Base.setindex!(cb::CircularBuffer, 
                        value, key::Int...;
                        getidx::Function=_get_circ_idx) # jfyi: `value::eltype(cb)` possible, but not necessary
    
    _key = map(k -> getidx(cb.head, k, cb.capcity), key)
    setindex!(cb.queue, value, _key...)

end

Base.first(cb::CircularBuffer) = cb.queue[cb.head] # TODO: cb.size == 0

Base.last(cb::CircularBuffer) = cb.queue[cb.tail] # TODO: cb.size == 0

function Base.push!(cb::CircularBuffer, item;
                    overwrite::Bool=false,
                    next::Function =_next_circ_idx) # TODO: isfull & overwrite 

    cb.tail = next(cb.tail, cb.capacity)

    cb.queue[cb.tail] = item

    cb.size += 1  # TODO: if overwrite >> 5 size should stay at 5

end

function Base.popfirst!(cb::CircularBuffer;
                        next::Function=_next_circ_idx)  # TODO: isempty 

    tmp = cb.queue[cb.head]

    cb.head = next(cb.head, cb.capacity)

    cb.size -= 1  # TODO: size should not be lower than 0

    return tmp

end

function Base.pushfirst!(cb::CircularBuffer, item;
                         getidx::Function=_get_prev_idx)

    cb.head = getidx(cb.head, cb.capacity)  # should not exceed capacity

    cb.queue[cb.head] = item

    cb.size += 1  # TODO: size should not be able to exceed capacity

end

function Base.pop!(cb::CircularBuffer;
                   getidx::Function=_get_prev_idx)

    tmp = cb.queue[cb.tail] # TODO: cb.tail can not be 0
    
    cb.tail = getidx(cb.tail, cb.capacity)

    size -= 1 # TODO: should not fall below 0

    return tmp

end

function Base.append!(cb::CircularBuffer, collections...;
                      overwrite::Bool=false)

    foreach(i -> push!(cb, i; overwrite=overwrite), vcat(collections...))

end

function convert(::Type{T}, cb::CircularBuffer) where {T <: AbstractArray}

    map(i -> getindex(cb, i), 1:cb.capacity) |> x -> convert(T, x)

end

==(cb::CircularBuffer, av::AbstractVector) = convert(Array, cb) == av
