"use strict"

Runner = require "runner/runner"

reserved = {}

module.exports = class IdentifierRunner extends Runner
  constructor: (interpreter, @name) ->
    super interpreter
  toString: -> @name

IdentifierRunner.create = (interpreter, name) ->
  runnerProvider = reserved[name] or IdentifierRunner
  runnerProvider.createMyself?(interpreter, name) or
    Runner.create.call runnerProvider, interpreter, name

IdentifierRunner.register = (name, runner) ->
  reserved[name] = runner
