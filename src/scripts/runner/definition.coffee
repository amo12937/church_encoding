"use strict"

Runner = require "runner/runner"

module.exports = class DefinitionRunner extends Runner
  constructor: (interpreter, @name, @body) ->
    super interpreter
  toString: -> "#{@name}: OK"

