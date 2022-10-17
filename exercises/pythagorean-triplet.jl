# attempt at the julean way (???)

# ==============
# data structure

struct PyTri
    target::Int
    start::Tuple{Int,Int}
end

# ===========
# constructor

PyTri(t::Int) = PyTri(t,(1,0))

# ==========
# interfaces

function Base.iterate(P::PyTri, state=P.start)
    
    i, n = state

    x = fld(P.target, 3)
    
    y = fld(P.target, 2)

    while i <= x 
        
        j = (n == 0 ? i : n) + 1
        
        n = 0

        while j <= y 

            k = P.target - i - j

            if (i * i + j * j == k * k)

                return (i, j, k), (i, j) 

            end
            
            j += 1

        end
    
        i += 1

    end

    return nothing

end

Base.IteratorSize(::Type{PyTri}) = Base.SizeUnknown()

Base.eltype(::Type{PyTri}) = Tuple{Int,Int,Int} # if tuple length unknown: e.g. `Tuple{Int, Int, Vararg{Int}}`

# ======
# 'main'

function pythagorean_triplets(target::Int)::Vector

    target < 3 && return []

    collect(PyTri(target)) 

end
