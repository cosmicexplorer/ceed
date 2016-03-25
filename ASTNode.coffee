# class defining elements of an ast node, for consumption by selectree

_ = require 'lodash'
util = require './util'

# for errors which imply the code is wrong, not this compiler
UserError = util.createExceptionType 'UserError'
# error if i made a mistake, not the user
ASTError = util.createExceptionType 'ASTError'

DoASTTypeCheck = (klass, args) ->
  if klass.constructor.TypeCheckArgs?
    unless klass.constructor.TypeCheckArgs(args...)
      throw new ASTError "AST Types do not match: #{klass.constructor.name}
      with [#{(el.toString() for el in args).join(',')}]"

class ASTNode

class Name extends ASTNode
  constructor: (@name) -> DoASTTypeCheck @constructor, arguments
  @TypeCheckArgs: _.isString

class UniqueName extends Name
  constructor: (@name) -> DoASTTypeCheck @constructor, arguments
  @TypeCheckArgs: _.isString

class NameRef extends ASTNode
  constructor: (@name) -> DoASTTypeCheck @constructor, arguments
  @TypeCheckArgs: _.isString

class TypeRef extends ASTNode
  constructor: (@name, @modifiers) -> DoASTTypeCheck @constructor, arguments
  @TypeCheckArgs: (name, modifiers) ->
    (name instanceof NameRef) and
    (modifiers instanceof Array) and (modifiers.every _.isString)

class AnonymousTypeRef extends TypeRef
  constructor: (@name, @modifiers) -> DoASTTypeCheck @constructor, arguments
  @TypeCheckArgs: (name, modifiers) ->
    (name instanceof TypeDeclaration) and (modifiers instanceof Array)

class Declaration extends ASTNode

class TypeDeclaration extends Declaration

class Typedef extends TypeDeclaration
  constructor: (@fromType, @toType) -> DoASTTypeCheck @constructor, arguments
  @TypeCheckArgs: (fromType, toType) ->
    (fromType instanceof TypeRef) and
    (toType instanceof UniqueName)

class StructDeclaration extends TypeDeclaration
  constructor: (@name, @members) -> DoASTTypeCheck @constructor, arguments
  @TypeCheckArgs: (name, members) ->
    nameOk = if name? then name instanceof UniqueName else yes
    if not members? then nameOk
    else
      membersOk = yes
      seenNames = {}
      for {memberName, memberType} in members
        if not ((memberName instanceof Name) and (memberType instanceof TypeRef))
          membersOk = no
          break
          if seenNames[memberName] throw new UserError "name #{memberName} used
            twice in struct #{name or "<anonymous>"}"
          else seenNames[memberName] = yes
    nameOk and membersOk

class EnumDeclaration extends TypeDeclaration
  constructor: (@name, @members) -> DoASTTypeCheck @constructor, arguments
  @TypeCheckArgs: (name, members) ->
    (if name? then name instanceof UniqueName else yes) and
    (members.every (mem) -> mem instanceof UniqueName)

class Value extends Declaration

class TopLevelValue extends Value
  constructor: (@isDefinition) -> DoASTTypeCheck @constructor, arguments
  @TypeCheckArgs: (isDefinition) -> typeof(isDefinition) is 'boolean'

class TopLevelVariable extends TopLevelValue
  constructor: (@type, @name, @specifiers, @isDefinition, @value) ->
    DoASTTypeCheck @constructor, arguments
  @TypeCheckArgs: (type, name, specifiers, isDefinition, value) ->
    tmp = (type instanceof TypeRef) and
    (name instanceof UniqueName) and
    (specifiers instanceof Array) and (specifiers.every _.isString) and
    (typeof(isDefinition) is 'boolean') and
    ((value? and isDefinition) or (not isDefinition and not value?))
    if not tmp then return false

    if value? then value instanceof Expression else yes

class TopLevelFunction extends TopLevelValue
  constructor: (@returnType, @argTypes, @isDefinition, @value, @specifiers) ->
    DoASTTypeCheck @constructor, arguments
  @TypeCheckArgs: (returnType, argTypes, isDefinition, value, specifiers) ->
    (returnType instanceof TypeRef) and
    (argTypes instanceof Array) and
    (argTypes.every (typ) -> typ instanceof TypeRef) and
    (typeof(isDefinition) is 'boolean') and

module.exports = {ASTNode}
