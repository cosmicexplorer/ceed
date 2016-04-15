# class defining elements of an ast node, for consumption by selectree

{getID} = require './IDGen'

class ASTNode
  constructor: -> @id = getID()

class Name extends ASTNode
  constructor: (@name) -> super

class UniqueName extends Name

class StructMember extends Name
  constructor: (name, @type) -> super name
  setEnclosingStruct: (@enclosingStruct) ->

class NameRef extends ASTNode
  constructor: (@name) -> super

class ValueRef extends NameRef
  setEnclosingScope: (@enclosingScope) ->

class LabelRef extends NameRef
  setEnclosingDefinition: (@enclosingDefinition) ->

class StructMemberNameRef extends NameRef

class FunctionDefinition extends ASTNode
  constructor: (@arguments, @definition) -> super

# these are convertible to each other!
class TypeRef extends ASTNode
  constructor: (@modifiers) -> super

class NamedTypeRef extends TypeRef
  constructor: (modifiers, @name) -> super modifiers

class AnonymousTypeRef extends TypeRef
  constructor: (modifiers, @impl) -> super modifiers

class Declaration extends ASTNode
  setEnclosingScope: (@enclosingScope) ->

# TODO: can also be used as a statement!
class TypeDeclaration extends Declaration

class Typedef extends TypeDeclaration
  constructor: (@fromType, @toType) -> super

class NewTypeDeclaration extends TypeDeclaration
  constructor: (@name = null) -> super

class StructDeclaration extends TypeDeclaration
  constructor: (name, @members) -> super name

class EnumDeclaration extends TypeDeclaration
  constructor: (name, @members) -> super name

class TopLevelValueDeclaration extends Declaration

class TopLevelVariable extends TopLevelValue
  constructor: (@type, @name, @specifiers, @value = null) -> super

class TopLevelFunction extends TopLevelValue
  constructor: (@returnType, @argTypes, @specifiers, @value = null) -> super

class GotoDeclaration extends Declaration
  constructor: (@label) -> super

class Statement extends ASTNode
  setEnclosingScope: (@enclosingScope) ->

class SimpleStatement extends Statement

class Expression extends SimpleStatement

# TODO: compute @outputType in AST pass
class RealExpression extends Expression

class FunctionCall extends RealExpression
  constructor: (@functionName, @arguments) -> super

class Literal extends RealExpression

class StringLiteral extends Literal
  constructor: (@content) -> super

class NumericLiteral extends Literal
  constructor: (@content) -> super

class VariableReference extends RealExpression
  constructor: (@ref) -> super

class BinaryOperator extends RealExpression
  constructor: (@left, @right) -> super

class Adds extends BinaryOperator

class Subtracts extends BinaryOperator

class Multiplies extends BinaryOperator

class Divides extends BinaryOperator

class Comma extends BinaryOperator

class Equals extends BinaryOperator

class NotEquals extends BinaryOperator

class BooleanAnds extends BinaryOperator

class BooleanOrs extends BinaryOperator

class BinaryAnds extends BinaryOperator

class BinaryOrs extends BinaryOperator

class BinaryXors extends BinaryOperator

class BinaryNots extends BinaryOperator

class Mods extends BinaryOperator

class LessThanCompares extends BinaryOperator

class GreaterThanCompares extends BinaryOperator

class LessThanEqualCompares extends BinaryOperator

class GreaterThanEqualCompares extends BinaryOperator

class LeftShifts extends BinaryOperator

class RightShifts extends BinaryOperator

class LValueBinaryOperator extends BinaryOperator

class Assigns extends LValueBinaryOperator

class AddsAssigns extends LValueBinaryOperator

class SubstractsAssigns extends LValueBinaryOperator

class MultipliesAssigns extends LValueBinaryOperator

class DividesAssigns extends LValueBinaryOperator

class AndsAssigns extends LValueBinaryOperator

class OrsAssigns extends LValueBinaryOperator

class XorsAssigns extends LValueBinaryOperator

class LeftShiftsAssigns extends LValueBinaryOperator

class RightShiftsAssigns extends LValueBinaryOperator

class Subscript extends LValueBinaryOperator

class MemberAccessOperator extends RealExpression
  constructor: (@expr, @memberName) -> super

class DotOperator extends MemberAccessOperator

class ArrowOperator extends MemberAccessOperator

class UnaryOperator extends RealExpression
  constructor: (@expr) -> super

class DereferenceOperator extends UnaryOperator

class ReferenceOperator extends UnaryOperator

class PreIncrementOperator extends UnaryOperator

class PostIncrementOperator extends UnaryOperator

class PreDecrementOperator extends UnaryOperator

class PostDecrementOperator extends UnaryOperator

class PlusUnaryOperator extends UnaryOperator

class MinusUnaryOperator extends UnaryOperator

class NotOperator extends UnaryOperator

class TernaryOperator extends RealExpression
  constructor: (@test, @ifTrue, @ifFalse) -> super

class ParenthesesOperator extends RealExpression
  constructor: (@expr) -> super

class ExplicitCast extends RealExpression
  constructor: (@castingType, @expr) -> super

class SometimesExpression extends Expression

class LocalVariable extends Expression
  constructor: (@type, @name, @value = null) -> super

class ControlStatement extends SimpleStatement

class ReturnStatement extends ControlStatement
  constructor: (@expr = null) -> super

class BreakStatement extends ControlStatement

class ContinueStatement extends ControlStatement

class GotoStatement extends ControlStatement
  constructor: (@label) -> super

class EmptyStatement extends ControlStatement

class Scope extends Statement

class SwitchCase extends ASTNode
  constructor: (@case, @body) -> super

class SwitchBlock extends Scope
  constructor: (@conditionClause, @cases) -> super

class SingleScope extends Scope
  constructor: (@body) -> super

class ForLoop extends SingleScope
  constructor: (@setupClause, @conditionClause, @advanceClause, body) ->
    super body

class WhileLoop extends SingleScope
  constructor: (@conditionClause, body) -> super body

class DoWhileLoop extends SingleScope
  constructor: (@conditionClause, body) -> super body

class IfBlock extends SingleScope
  constructor: (@conditionClause, body) -> super body

class ElseBlock extends SingleScope

class OpenScope extends SingleScope

module.exports = {
  ASTNode
  Name
  UniqueName
  StructMember
  NameRef
  ValueRef
  LabelRef
  StructMemberNameRef
  FunctionDefinition
  TypeRef
  NamedTypeRef
  AnonymousTypeRef
  Declaration
  TypeDeclaration
  Typedef
  NewTypeDeclaration
  StructDeclaration
  EnumDeclaration
  TopLevelValueDeclaration
  TopLevelVariable
  TopLevelFunction
  GotoDeclaration
  Statement
  SimpleStatement
  Expression
  RealExpression
  FunctionCall
  Literal
  StringLiteral
  NumericLiteral
  VariableReference
  BinaryOperator
  Adds
  Subtracts
  Multiplies
  Divides
  Comma
  Equals
  NotEquals
  BooleanAnds
  BooleanOrs
  BinaryAnds
  BinaryOrs
  BinaryXors
  BinaryNots
  Mods
  LessThanCompares
  GreaterThanCompares
  LessThanEqualCompares
  GreaterThanEqualCompares
  LeftShifts
  RightShifts
  LValueBinaryOperator
  Assigns
  AddsAssigns
  SubstractsAssigns
  MultipliesAssigns
  DividesAssigns
  AndsAssigns
  OrsAssigns
  XorsAssigns
  LeftShiftsAssigns
  RightShiftsAssigns
  Subscript
  MemberAccessOperator
  DotOperator
  ArrowOperator
  UnaryOperator
  DereferenceOperator
  ReferenceOperator
  PreIncrementOperator
  PostIncrementOperator
  PreDecrementOperator
  PostDecrementOperator
  PlusUnaryOperator
  MinusUnaryOperator
  NotOperator
  TernaryOperator
  ParenthesesOperator
  ExplicitCast
  SometimesExpression
  LocalVariable
  ControlStatement
  ReturnStatement
  BreakStatement
  ContinueStatement
  GotoStatement
  EmptyStatement
  Scope
  SwitchCase
  SwitchBlock
  SingleScope
  ForLoop
  WhileLoop
  DoWhileLoop
  IfBlock
  ElseBlock
  OpenScope
}
