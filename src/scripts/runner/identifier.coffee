"use strict"

runnerFactory = require("runner/factory")
stdlib = require "visitor/stdlib"
Runner = require "runner/runner"

runners = {}

module.exports = class IdentifierRunner extends Runner
  constructor: (interpreter, @name) ->
    super interpreter
  run: (thunk) ->
    return runners[@name]?.run(thunk) or
      stdlib.env[@name]?.get().run(thunk) or
      thunk.get()
  toString: -> @name

runnerFactory.register "IDENTIFIER", (interpreter, name) ->
  runners[name] or IdentifierRunner.create interpreter, name

IdentifierRunner.register = (name, runnerProvider) ->
  runners[name] = runnerProvider.create stdlib, name
