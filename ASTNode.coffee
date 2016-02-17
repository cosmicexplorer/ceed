# class defining elements of an ast node, for consumption by selectree

class ASTNode
  constructor: (@name, children) ->
    @_children = children.map (ch) ->
      if not (ch instanceof ASTNode)
        if not isNaN(parseInt(ch))
          new ASTNode('CONSTANT', [new ASTNode(ch, [])])
        else if ch.match /[a-zA-Z_][a-zA-Z_0-9]+/
          new ASTNode('IDENTIFIER', [new ASTNode(ch, [])])
        else new ASTNode(ch, [])
      else ch
  name: -> @name
  children: -> @_children

module.exports = {ASTNode}
