AST
===

AST node reference. Implemented in [ASTNode.coffee](ASTNode.coffee).

A `Name` is a token newly created in a declaration which must be unique. `?` before a field means it is optional. `NameRef` resolves to a type or a value of some type during type checking, and to a location in memory during codegen.

# Name
A token denoting the name of something.

- name: `SomeString`

## UniqueName
A token newly created in a declaration, which must be unique within its enclosing scope (but can be shadowed in lower scopes).

## UniqueLabel
Similar to UniqueName, but for goto statements.

- enclosingDefinition: `FunctionDefinition`

## StructMemberName
Must be unique within a struct.

- enclosingStruct: `StructDeclaration`

# NameRef
Resolves to whatever is denoted by the name.

- name: `SomeString`

## ValueRef
- enclosingScope: `Scope`

## LabelRef
Same as ValueRef, but for gotos.

- enclosingDefinition: `FunctionDefinition`

## StructMemberNameRef

# FunctionDefinition
- arguments: list<`LocalVariable`>
- definition: `OpenScope`

# TypeRef
Not a declaration!
- modifiers: list<`SomeString`>

## NamedTypeRef
- name: `ValueRef`

## AnonymousTypeRef
- impl: `NewTypeDeclaration`

# Declaration

All of these have an enclosingScope: `Scope`, which may be global.

## TypeDeclaration
Also inherits from `Statement`!

- Typedef
    - fromType: `TypeRef`
    - toType: `UniqueName`

### NewTypeDeclaration
- StructDeclaration
    - ?name: `UniqueName`
    - ?members: list< {memberName: `StructMemberName`, memberType: `TypeRef`} >
- EnumDeclaration
    - ?name: `UniqueName`
    - members: list< {name: `UniqueName`, ?num: `int`} >

## ValueDeclaration
All of these have a field isDefinition, which determines whether it is a declaration or definition. This can be viewed as a `bool` or an `enum`. A static pass (before type-checking) over the AST will determine whether there is more than one definition. If isDefinition is set to "definition" (or `true`), then a "value" field is allowed. This may be performed during creation of the AST during parsing, or as a separate pass over the AST before type-checking.

- TopLevelVariable
    - type: `TypeRef`
    - name: `UniqueName`
    - specifiers: list<`SomeString`>
    - isDefinition: `bool` (or enum)
    - ?value: `Expression`
- TopLevelFunction
    - returnType: `TypeRef`
    - argTypes: list<`TypeRef`>
    - isDefinition: `bool` (or enum)
    - ?value: list<`LocalVariable`>, definition: `OpenScope`
    - specifiers: list<`SomeString`>

## GotoDeclaration

- GotoDeclaration
    - label: `UniqueLabel`

# Statement

All of these things have an enclosing scope, which may be anything subclassing `Scope` (function definitions are `OpenScope`s).

- enclosingScope: `Scope`

## SimpleStatement
### Expression
#### RealExpression
All expressions have types, which are computed in an AST pass.

- FunctionCall
    - functionName: `ValueRef`
    - arguments: list<`RealExpression`>
- Literal
    - options:
        - StringLiteral {content: `SomeString`}
        - NumericLiteral {content: `NumericConstant`}
        - ReferenceLiteral
            - `ValueRef`
                - function/variable reference (not function call!!)
- BinaryOperator
    - left: `RealExpression`
    - right: `RealExpression`
    - split into specializations of:
        - `+`|`-`|`*`|`/`|`=`|`+=`|`-=`|`*=`|`/=`|`,`|`==`|`!=`|`&&`|`||`|`&`|`^`|`|`|`~`|`%`|`>`|`<`|`<=`|`>=`|`&=`|`|=`|`^=`|`<<`|`>>`|`<<=`|`>>=`|`[]`
- MemberAccessOperator
    - expr: `RealExpression`
    - memberName: `StructMemberNameRef`
    - split into specializations of:
        - `.`|`->`
- UnaryOperator
    - split into specializations of:
        - `*`|`&`|`++`(pre)|`++`(post)|`--`(pre)|`--`(post)|`+`|`-`|`!`
    - expr: `RealExpression`
- TernaryOperator
    - test: `RealExpression`
    - ifTrue: `RealExpression`
    - ifFalse: `RealExpression`
- ParenthesesOperator
    - expr: `RealExpression`
- ExplicitCast
    - castingType: `TypeRef`
    - expr: `RealExpression`

#### SometimesExpression
Things that are expressions, but only in the beginning of parts of if/while/for blocks. For compound variable assignments (`int a = 3, b = 2`), let's just make them into a list of variable assignments. I'm pretty sure that's allowed.

- LocalVariable
    - type: `TypeRef`
    - name: `UniqueName`
    - ?value: `RealExpression`
        - not necessary; memory always allocated either way (modulo optimizations)
    - specifiers: list<`SomeString`>
    - used for function arguments
    - this is also an expression, and also a statement!


### ControlStatement
- ReturnStatement
    - ?expr: `RealExpression`
- BreakStatement
- ContinueStatement
- GotoStatement
    - label: `LabelRef`
- EmptyStatement

## Scope
all have (body: list<`Statement`>)
- ForLoop
    - setupClause: `Expression`
    - conditionClause: `Expression`
    - advanceClause: `RealExpression`
- WhileLoop
    - conditionClause: `Expression`
- DoWhileLoop
    - conditionClause: `Expression`
- IfBlock
    - conditionClause: `Expression`
- ElseBlock
- OpenScope `{}`
