"use strict"

Runner = require "runner/runner"

reserved = {}

module.exports = class IdentifierRunner extends Runner
  constructor: (interpreter, @name) ->
    super interpreter
  toString: -> @name

IdentifierRunner.create = (interpreter, name) ->
  Runner.create.call (reserved[name] or IdentifierRunner), interpreter, name

IdentifierRunner.register = (name, runner) ->
  reserved[name] = runner
