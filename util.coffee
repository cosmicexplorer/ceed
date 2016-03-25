createExceptionType = (name) ->
  fn = ->
    err = new Error arguments...
    err.name = @name = name
    @stack = err.stack
    @message = err.message
  fn.prototype = Object.create Error.prototype,
    constructor:
      value: fn
      writeable: yes
      configurable: yes
  fn

module.exports = {createExceptionType}
