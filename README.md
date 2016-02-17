ceed
====

IT'S CALLED CEED BECAUSE IT MAKES A **TREE** FROM C CODE GET IT

Produces an AST from preprocessed C source code using jison, a C grammar, and some sunlight.

This is a library producing nodes suitable for [selectree](https://github.com/cosmicexplorer/selectree). Anything that modifies syntax goes here. This shouldn't require a lot of changes after it's written.

# TODO

1. actually generate nodes
2. Use line number output from cpp as specified [here](https://gcc.gnu.org/onlinedocs/cpp/Preprocessor-Output.html). Remove the `-P` from the test command.
    - can preprocess in [the driver](driver.coffee)
        - form sorted map of input lines from `cpp` to line numbers as given
        - use `count()` function from [here](https://www.lysator.liu.se/c/ANSI-C-grammar-l.html) to get line/col of UNMARKED (no line number) input from `cpp`
        - to find line/col of any given node, find the input line in sorted map which is closest to, but before the given node
        - find relative line/col from the ast node at the line matching the input line you just found, add to entry in sorted map to get absolute location of current ast node
