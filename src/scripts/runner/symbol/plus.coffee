"use strict"

IdentifierRunner = require "runner/identifier"
NumberRunner = require "runner/number"
LambdaAbstractionRunner = require "runner/lambda_abstraction"
BradeRunner = require "runner/brade"
tokenizer = require "tokenizer"
parser = require "parser"

# + := \m n f x.m f (n f x)
code = "\\m n f x.m f (n f x)"
ast = parser.parse(tokenizer.tokenize code).exprs[0]

module.exports = class PlusSymbolRunner extends IdentifierRunner
  run: (mThunk) ->
    i = @interpreter
    toS = -> "\\n f x.m f (n f x)"
    return BradeRunner.create i, toS, (nThunk) ->
      m = mThunk.get()
      n = nThunk.get()
      if m instanceof NumberRunner and n instanceof NumberRunner
        return NumberRunner.create i, m.value + n.value
      lmda = LambdaAbstraction.create i, ast.arg, ast.body
      return lmda.run(mThunk).run(nThunk)

IdentifierRunner.register "+", PlusSymbolRunner
