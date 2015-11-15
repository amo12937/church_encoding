"use strict"

runnerFactory = require("runner/factory")
Runner = require "runner/runner"

module.exports = class DefinitionRunner extends Runner
  constructor: (interpreter, @name, @body) ->
    super interpreter
  toString: -> "OK: #{@name}"

runnerFactory.register "DEFINITION", (interpreter, name, body) ->
  DefinitionRunner.create interpreter, name, body

