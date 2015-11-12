"use strict"

Runner = require "runner/runner"
BradeRunner = require "runner/brade"
FutureEval = require "future_eval"

module.exports = class NumberRunner extends Runner
  constructor: (interpreter, @value) ->
    super interpreter
  run: (fThunk) ->
    return Runner.create @interpreter if @value is 0
    f = fThunk.get()
    return f if @value is 1

    if f instanceof NumberRunner
      val = Math.pow f.value, @value
      return NumberRunner.create @interpreter, val

    # n f x -> f ((n-1) f x)
    m = @value - 1
    i = @interpreter
    toS = -> "f (#{m} f x)"
    BradeRunner.create i, toS, (xThunk) ->
      f.run FutureEval.createWithGetter ->
        NumberRunner.create(i, m).run(fThunk).run(xThunk)
  toString: -> "#{@value}"

