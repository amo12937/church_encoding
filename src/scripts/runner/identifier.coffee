"use strict"

Runner = require "runner/runner"

module.exports = class IdentifierRunner extends Runner
  constructor: (interpreter, @name) ->
    super interpreter
  toString: -> @name
