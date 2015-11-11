"use strict"

IdentifierRunner = require "runner/identifier"
BradeRunner = require "runner/brade"
LambdaAbstractionRunner = require "runner/lambda_abstraction"

module.exports = {
  TrueIdentifierRunner
  FalseIdentifierRunner
  # AndSymbolRunner
  #  OrSymbolRunner
  # NotSymbolRunner
}

# true := \x y.x
class TrueIdentifierRunner extends IdentifierRunner
  run: (xThunk) ->
    toS = -> "\\y.x"
    return BradeRunner.create @identifier, toS, -> xThunk.get()
IdentifierRunner.register "true", TrueIdentifierRunner

# false := \x y.y
class FalseIdentifierRunner extends IdentifierRunner
  run: ->
    toS = -> "\\y.y"
    return BradeRunner.create @identifier, toS, (yThunk) -> yThunk.get()
IdentifierRunner.register "false", FalseIdentifierRunner

# and := \p q.p q false
andCode = "\\p q.p q false"
IdentifierRunner.register "and", LambdaAbstractionRunner.runnerWithCode andCode

# or := \p q.p q
orCode = "\\p q.p true q"
IdentifierRunner.register "or", LambdaAbstractionRunner.runnerWithCode orCode


