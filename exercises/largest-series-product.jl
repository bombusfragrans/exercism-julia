function largest_product(str, span)
    (span < 0 || 
    length(str) < span ||   # also covers case: 'empty string and nonzero span
    any(!isnumeric, str)) &&
    throw(ArgumentError("Arguments invalid"))
    [begin
        str[i:min(i + span - 1, end)] |>
        collect |> 
        v -> parse.(Int, v) |> 
        prod 
    end
    for i in 1:length(str)-(span - 1)] |>
    maximum # if all digits are zero or all chunks contain zero then the maximum of all products is also zero
end
