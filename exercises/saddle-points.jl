function saddlepoints(M)
    isempty(M) && return M
    r = findmax(M, dims = 2)[1] 
    c = findmin(M, dims = 1)[1]
    [(x,y) for x=1:length(r), y=1:length(c) if r[x] == c[y]]
end
