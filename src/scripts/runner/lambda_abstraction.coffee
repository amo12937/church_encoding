"use strict"

runnerFactory = require("runner/factory")
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

runnerFactory.register "LAMBDA_ABSTRACTION", (interpreter, arg, body) ->
  LambdaAbstractionRunner.create interpreter, arg, body

