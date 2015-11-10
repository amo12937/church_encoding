"use strict"

Runner = require "runner/runner"
toStringVisitor = require("visitor/to_string_visitor").create()

module.exports = class LambdaAbstractionRunner extends Runner
  constructor: (interpreter, @arg, @body) ->
    super interpreter
  run: (thunk) ->
    i = @interpreter.createChild()
    i.env[@arg] = thunk
    return @body.accept i
  toString: ->
    "\\#{@arg}.#{@body.accept toStringVisitor}"
