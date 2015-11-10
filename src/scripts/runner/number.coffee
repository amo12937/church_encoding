"use strict"

Runner = require "runner/runner"
BradeRunner = require "runner/brade"
FutureEval = require "future_eval"

module.exports = class NumberRunner extends Runner
  constructor: (interpreter, @value) ->
    super interpreter
  run: (thunk) ->
    return Runner.create @interpreter if @value is 0
    r = thunk.get()
    return r if @value is 1

    if r instanceof NumberRunner
      val = Math.pow r.value, @value
      return NumberRunner.create @interpreter, val

    # n f x -> f ((n-1) f x)
    m = @value - 1
    i = @interpreter
    toS = -> "f (#{m} f x)"
    BradeRunner.create i, toS, (thunk2) ->
      r.run FutureEval.createWithGetter ->
        NumberRunner.create(i, m).run(thunk).run(thunk2)
  toString: -> "#{@value}"

