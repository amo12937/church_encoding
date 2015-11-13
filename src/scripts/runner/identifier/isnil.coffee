"use strict"

IdentifierRunner = require "runner/identifier"
NilIdentifierRunner = require "runner/identifier/nil"

module.exports = class IsnilIdentifierRunner extends IdentifierRunner
  run: (nilThunk) ->
    n = nilThunk.get()
    if n instanceof NilIdentifierRunner
      return @interpreter.env.true.get()
    return @interpreter.env.false.get()
IdentifierRunner.register "isnil", IsnilIdentifierRunner

