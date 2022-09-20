## Steps taken and results recieved:
1. draft isbn-verifier.jl (see attached file): wrote a custom `subtypes` function (see `isbn_subtypes()`)
2. in terminal
```bash
julia runtests.jl    # see attached file
```
3. test results:
```bash
Test Summary:           | Pass  Total
valid ISBNs don't throw |    4      4
Test Summary:                   | Pass  Total
invalid ISBNs throw DomainError |   15     15
Test Summary:                                    | Pass  Total
ISBNs compare equal when they're the same number |    1      1
```
4. submit to exercism: `exercism isbn-verfier.jl
5. result in exercism overview: FAILED; for error see testerror.md
