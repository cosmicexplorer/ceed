ceed
====

IT'S CALLED CEED BECAUSE IT MAKES A **TREE** FROM C CODE *GET IT*

Produces an AST from preprocessed C source code using jison, a C grammar, and some sunlight. Use [selectree][] to manipulate tree for any mid-end optimizations (none implemented yet). Finally, have LLVM/C backends to produce working binaries with the help of [llc][], or view the result of optimizations as formatted C code (shelling out to [clang-format][]). Packaged as a command-line program and a library.

# TODO

- [x] actually generate nodes *2016-02-19*
- [x] abstract AST from parse tree
- [ ] generate bookkeeping structure separate from program memory for ast nodes
    - big ol hash table
    - allows for serializability (gimple)
- [ ] generate basic IR from nodes for some small example program
- [ ] generate valid IR for "hello world" program
- [ ] generate valid IR for arbitrary programs
- [ ] demonstrate utility by implementing mid-end optimizations through use of [selectree][]
- [ ] generate C from nodes
    - view result of optimizations in real time
    - can live modify optimization code, or input code to see how to satisfy optimization constraints

## Usability Improvements

- [ ] Use line number output from cpp as specified [here](https://gcc.gnu.org/onlinedocs/cpp/Preprocessor-Output.html). Remove the `-P` from the test command.
    - can preprocess in [the driver](driver.coffee)
        - form sorted map of input lines from `cpp` to line numbers as given
        - use `count()` function from [here](https://www.lysator.liu.se/c/ANSI-C-grammar-l.html) to get line/col of UNMARKED (no line number) input from `cpp`
        - to find line/col of any given node, find the input line in sorted map which is closest to, but before the given node
        - find relative line/col from the ast node at the line matching the input line you just found, add to entry in sorted map to get absolute location of current ast node
    - can use `yy-*` from jison to easily get line/col
- [ ] Generate attributes (for consumption by selectree) dynamically from members depending upon node type.
    - merge objects produced by `super()` and anything node-specific
    - this allows for common attributes like line/col, but also node-specific attributes like storage class specifiers
    - this would involve redoing the class hierarchy instead of the flat "everything is an AST node" like we have now
        - maybe mixins too

[selectree]: https://github.com/cosmicexplorer/selectree
[llc]: http://llvm.org/docs/CommandGuide/llc.html
[clang-format]: http://clang.llvm.org/docs/ClangFormat.html
