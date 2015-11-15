"use strict"

module.exports = class Runner
  constructor: (@interpreter) -> undefined
  run: (thunk) -> thunk.get()

Runner.create = ->
  return new (Function.prototype.bind.apply @, [@, arguments...])

