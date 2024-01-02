function sum_of_multiples(limit, factors)
    factors = filter(>(0), factors)
    isempty(factors) && return 0
    [f:f:limit-1 for f in factors if !any(x -> f % x == 0, filter(!=(f), factors))] |> 
    x -> union(x...) |> 
    sum
end
