"use strict"

Runner = require "runner/runner"

stdlib = null
runners = {}

module.exports = class IdentifierRunner extends Runner
  constructor: (interpreter, @name) ->
    super interpreter
  run: (thunk) ->
    return r if runners[@name]? and r = runners[@name].run thunk
    return stdlib.env[@name]?.get().run(thunk) or thunk.get()
  toString: -> @name

IdentifierRunner.setStdlib = (s) ->
  stdlib = s

IdentifierRunner.register = (name, runnerProvider) ->
  runners[name] = runnerProvider.create stdlib, name
