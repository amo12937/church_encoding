"use strict"

IdentifierRunner = require "runner/identifier"
NumberRunner = require "runner/number"

# succ := \n f x.f (n f x)
module.exports = class SuccIdentifierRunner extends IdentifierRunner
  run: (nThunk) ->
    n = nThunk.get()
    if n instanceof NumberRunner
      return NumberRunner.create @interpreter, n.value + 1
    return @interpreter.env[@name]?.get().run nThunk

IdentifierRunner.register "succ", SuccIdentifierRunner
