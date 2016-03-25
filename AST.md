AST
===

AST node reference.

A `Name` is a token newly created in a declaration which must be unique. `?` before a field means it is optional. `NameRef` resolves to a type or a value of some type during type checking, and to a location in memory during codegen.

# TypeRef
Not a declaration!
- modifiers: list<`SomeString`>
- name: `NameRef`

## AnonymousTypeRef
- name: `TypeDeclaration`

# Declaration
## TypeDeclaration
- typedef
    - fromType: `TypeRef`
    - toType: `Name`
- struct
    - ?name: `Name`
    - ?members: list< pair<`TypeRef`, `Name`> >
- enum
    - ?name: `Name`
    - members: list<`Name`>

## Value
### TopLevelValue
All of these have a field declarationOrDefinition, which determines whether it is a declaration or definition. This can be viewed as a `bool` or an `enum`. A static pass (before type-checking) over the AST will determine whether there is more than one definition. If declarationOrDefinition is set to "definition", then a "value" field is allowed. This may be performed during creation of the AST during parsing, or as a separate pass over the AST before type-checking.

- variable
    - type: `TypeRef`
    - name: `Name`
    - specifiers: list<`SomeString`>
    - declarationOrDefinition: `bool` (or enum)
    - ?value: `Expression`
- function
    - returnType: `TypeRef`
    - argTypes: list<`TypeRef`>
    - declarationOrDefinition: `bool` (or enum)
    - ?value: list<`Variable[InsideFunc]`>, definition: `OpenScope`
    - specifiers: list<`SomeString`>

### InsideFuncValue
All have an enclosingScope: `Scope`.

- gotoDecl
    - label: `Name`

# Statement

All of these things have an enclosing scope, which may be anything subclassing `Scope` (function definitions are `OpenScope`s).

- enclosingScope: `Scope`

## Simple
### Expression
#### RealExpression
All expressions have types, which are computed in an AST pass.

- function call
    - functionName: `NameRef`
    - arguments: list<`RealExpression`>
- literal
    - options:
        - string literal
        - numeric literal
        - `NameRef`
            - function/variable reference (not function call!!)
- binaryOperator
    - name: `+`|`-`|`*`|`/`|`=`|`+=`|`-=`|`,`
    - left: `RealExpression`
    - right: `RealExpression`
- unaryOperator
    - name: `*`|`&`|`++`(pre)|`++`(post)|`--`(pre)|`--`(post)
    - expr: `RealExpression`

#### SometimesExpression
Things that are expressions, but only in the beginning of parts of if/while/for blocks. For compound variable assignments (`int a = 3, b = 2`), let's just make them into a list of variable assignments. I'm pretty sure that's allowed.

- localVariable
    - type: `TypeRef`
    - name: `Name`
    - ?value: `RealExpression`
        - not necessary; memory always allocated either way (modulo optimizations)
    - specifiers: list<`SomeString`>
    - used for function arguments
    - this is also an expression, and also a statement!


### Control
- return
    - ?expr: `RealExpression`
- break
- continue
- goto
    - label: `NameRef`

## Scope
- for
    - setupClause: `Expression`
    - conditionClause: `Expression`
    - advanceClause: `RealExpression`
    - body: list<`Statement`>
- while
    - conditionClause: `Expression`
    - body: list<`Statement`>
- do/while
    - conditionClause: `Expression`
    - body: list<`Statement`>
- if
    - conditionClause: `Expression`
    - body: list<`Statement`>
- else
    - body: list<`Statement`>
- open scope `{}`
    - body: list<`Statement`>

# Body
Things that can go inside a function body.

- lines: list<`Statement`|`TypeDeclaration`>
