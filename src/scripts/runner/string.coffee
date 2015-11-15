"use strict"

runnerFactory = require("runner/factory")
Runner = require "runner/runner"
NumberRunner = require "runner/number"
FutureEval = require "future_eval"

module.exports = class StringRunner extends Runner
  constructor: (interpreter, @text) ->
    super interpreter
  run: (pThunk) ->
    i = @interpreter
    t = @text
    return @ if t is ""
    return pThunk.get().run(
      FutureEval.createWithGetter ->
        NumberRunner.create i, t.charCodeAt 0
    ).run(
      FutureEval.createWithGetter ->
        StringRunner.create i, t[1..]
    )

  toString: -> "\"#{@text}\""

runnerFactory.register "STRING", (interpreter, text) ->
  StringRunner.create interpreter, text

