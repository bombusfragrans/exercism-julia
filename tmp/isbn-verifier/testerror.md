## 5 TEST FAILURES

e.g.

### CODE RUN

```julia
@test begin
    ISBN("3-598-21508-8")
    true
end
```
### TEST ERROR
```juia
DomainError with Union{}[]:
input not a valid ISBN string
Stacktrace:
  [1] ERR(x::Vector{Union{}}, s::String)
    @ ExercismTestReports ./isbn-verifier.jl:11
  [2] STR_ERR(x::Vector{Union{}}; e::typeof(ExercismTestReports.ERR))
    @ ExercismTestReports ./isbn-verifier.jl:17
  [3] STR_ERR(x::Vector{Union{}})
    @ ExercismTestReports ./isbn-verifier.jl:17
  [4] #isValidStr#24
    @ ./isbn-verifier.jl:71 [inlined]
  [5] isValidStr
    @ ./isbn-verifier.jl:71 [inlined]
  [6] getSubtype(s::String, t::Vector{Union{}}; dm::typeof(ExercismTestReports.doesMatch), vs::typeof(ExercismTestReports.isValidStr))
    @ ExercismTestReports ./isbn-verifier.jl:87
  [7] getSubtype(s::String, t::Vector{Union{}}) (repeats 2 times)
    @ ExercismTestReports ./isbn-verifier.jl:82
  [8] ExercismTestReports.ISBN(s::String)
    @ ExercismTestReports ./isbn-verifier.jl:35
  [9] macro expansion
    @ /usr/local/julia/share/julia/stdlib/v1.8/Test/src/Test.jl:464 [inlined]
 [10] macro expansion
    @ ./runtests.jl:20 [inlined]
 [11] macro expansion
    @ /usr/local/julia/share/julia/stdlib/v1.8/Test/src/Test.jl:1357 [inlined]
 [12] top-level scope
    @ ./runtests.jl:20
    ```
    
