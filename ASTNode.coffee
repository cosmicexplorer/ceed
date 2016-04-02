# class defining elements of an ast node, for consumption by selectree

{getID} = require './IDGen'
_ = require 'lodash'
util = require './util'

class ASTNode
  constructor: -> @id = getID()

class Name extends ASTNode
  constructor: (@name) -> super

class UniqueName extends Name
  constructor: (@name) -> super

class NameRef extends ASTNode
  constructor: (@name) -> super

class TypeRef extends ASTNode
  constructor: (@name, @modifiers) -> super

class AnonymousTypeRef extends TypeRef
  constructor: (@name, @modifiers) -> super

class Declaration extends ASTNode

class TypeDeclaration extends Declaration

class Typedef extends TypeDeclaration
  constructor: (@fromType, @toType) -> super

class StructDeclaration extends TypeDeclaration
  constructor: (@name, @members) -> super

class EnumDeclaration extends TypeDeclaration
  constructor: (@name, @members) -> super

class Value extends Declaration

class TopLevelValue extends Value
  constructor: (@isDefinition) -> super

class TopLevelVariable extends TopLevelValue
  constructor: (@type, @name, @specifiers, @isDefinition, @value) -> super

class TopLevelFunction extends TopLevelValue
  constructor: (@returnType, @argTypes, @isDefinition, @value, @specifiers) ->
    super

module.exports = {
  ASTNode
  Name
  UniqueName
  NameRef
  TypeRef
  AnonymousTypeRef
  Declaration
  TypeDeclaration
  Typedef
  StructDeclaration
  EnumDeclaration
  Value
  TopLevelValue
  TopLevelVariable
  TopLevelFunction
}
