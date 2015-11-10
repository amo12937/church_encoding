"use strict"

IdentifierRunner = require "runner/identifier"
NumberRunner = require "runner/number"
BradeRunner = require "runner/brade"
FutureEval = require "future_eval"

# succ := \n f x.f (n f x)
name = "succ"
module.exports = class SuccIdentifierRunner extends IdentifierRunner
  run: (nThunk) ->
    i = @interpreter
    n = nThunk.get()
    if n instanceof NumberRunner
      return NumberRunner.create i, n.value + 1

    toS1 = -> "\\f x.f (n f x)"
    return BradeRunner.create i, toS1, (fThunk) ->
      toS2 = -> "\\x.f (n f x)"
      return BradeRunner.create i, toS2, (xThunk) ->
        fThunk.get().run FutureEval.createWithGetter ->
          n.run(fThunk).run(xThunk)

IdentifierRunner.register name, SuccIdentifierRunner

