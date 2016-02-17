# class defining elements of an ast node, for consumption by selectree

class ASTNode
  constructor: (@name, @_children) ->
  name: -> @name
  children: -> @_children

module.exports = {ASTNode}
