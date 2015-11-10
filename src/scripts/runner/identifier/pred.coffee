"use strict"

IdentifierRunner = require "runner/identifier"
NumberRunner = require "runner/number"
LambdaAbstractionRunner = require "runner/lambda_abstraction"
tokenizer = require "tokenizer"
parser = require "parser"

# pred := \n f x.n (\g h.h (g f)) (\u.x) (\v.v)
code = "\\n f x.n (\\g h.h (g f)) (\\u.x) (\\v.v)"
ast = parser.parse(tokenizer.tokenize code).exprs[0]

module.exports = class PredIdentifierRunner extends IdentifierRunner
  run: (nThunk) ->
    i = @interpreter
    n = nThunk.get()
    if n instanceof NumberRunner
      return NumberRunner.create i, Math.max(0, n.value - 1)

    lmda = LambdaAbstractionRunner.create i, ast.arg, ast.body
    return lmda.run nThunk

IdentifierRunner.register "pred", PredIdentifierRunner
