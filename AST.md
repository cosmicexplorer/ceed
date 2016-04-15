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

- type: `TypeRef`
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

### Typedef
- fromType: `TypeRef`
- toType: `UniqueName`

### NewTypeDeclaration
- ?name: `UniqueName`

- StructDeclaration
    - members: list< {memberName: `StructMemberName`, memberType: `TypeRef`} >
- EnumDeclaration
    - members: list< {name: `UniqueName`, ?num: `int`} >

## TopLevelValueDeclaration
- check if value is non-null to see if there's a definition attached; if so, make sure only one exists
- also make sure all the declarations agree with each other

- TopLevelVariable
    - type: `TypeRef`
    - name: `UniqueName`
    - specifiers: list<`SomeString`>
    - ?value: `Expression`
- TopLevelFunction
    - returnType: `TypeRef`
    - argTypes: list<`TypeRef`>
    - specifiers: list<`SomeString`>
    - ?value: `FunctionDefinition`
        - check to make sure local variable types match argTypes

## GotoDeclaration

- GotoDeclaration
    - label: `UniqueLabel`

# Statement

All of these things have an enclosing scope, which may be anything subclassing `Scope` (function definitions are `OpenScope`s).

- enclosingScope: `Scope`

## SimpleStatement
### Expression
#### RealExpression
All RealExpressions have types, which are computed in an AST pass.

- outputType: `TypeRef`
    - computed in AST pass, NOT at construction

- FunctionCall
    - function: `RealExpression`
    - arguments: list<`RealExpression`>
- Literal
    - options:
        - StringLiteral {content: `SomeString`}
        - NumericLiteral {content: `NumericConstant`}
- VariableReference
    - ref: `ValueRef`
- BinaryOperator
    - left: `RealExpression`
    - right: `RealExpression`
    - `+`|`-`|`*`|`/`|`,`|`==`|`!=`|`&&`|`||`|`&`|`^`|`|`|`%`|`>`|`<`|`<=`|`>=`|`<<`|`>>`
- LValueBinaryOperator
    - left: `RealExpression`
        - convertible into lvalue!
    - right: `RealExpression`
    - `=`|`+=`|`-=`|`*=`|`/=`|`&=`|`|=`|`^=`|`<<=`|`>>=`|`%=`|`[]`
- MemberAccessOperator
    - expr: `RealExpression`
    - memberName: `StructMemberNameRef`
    - split into specializations of:
        - `.`|`->`
- UnaryOperator
    - split into specializations of:
        - `*`|`&`|`++`(pre)|`++`(post)|`--`(pre)|`--`(post)|`+`|`-`|`!`|`~`|`sizeof`
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
Things that are expressions, but only in the beginning of parts of if/while/for/switch blocks. For compound variable assignments (`int a = 3, b = 2`), let's just make them into a list of variable assignments. I'm pretty sure that's allowed.

- LocalVariable
    - type: `TypeRef`
    - name: `UniqueName`
    - ?value: `RealExpression`
        - not necessary; memory always allocated either way (modulo optimizations)
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
all end up creating a new scope

### SwitchBlock
- define type `SwitchCase` to be Either<`NumericLiteral`, `Name`, `Expression`>, where all recursive operands of `Expression` are `NumericLiterals`, and all `Name`s refer to enums or other constant expressions
    - during typechecking this MUST resolve to a constant expression!
- conditionClause: `Expression`
- cases: list<pair<`SwitchCase`, list<`Statement`>>>

### SingleScope
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
