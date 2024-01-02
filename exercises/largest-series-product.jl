function largest_product(str, span)
    (span < 0 || 
    length(str) < span ||   # also covers case: 'empty string and nonzero span
    any(!isnumeric, str)) &&
    throw(ArgumentError("Arguments invalid"))
    collect(str) |> 
    v -> parse.(Int, v) |>  # collect and broadcasting is required to preserve leading zeros 
    s -> [begin
        s[i:min(i + span - 1, end)] |>
        prod 
    end
    for i in 1:length(s)-(span - 1)] |>
    maximum # if all digits are zero or all chunks contain zero then the maximum of all products is also zero
end
