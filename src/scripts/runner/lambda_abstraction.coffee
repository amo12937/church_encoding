"use strict"

Runner = require "runner/runner"
toStringVisitor = require("visitor/to_string_visitor").create()
tokenizer = require "tokenizer"
parser = require "parser"
AST = require "AST"

module.exports = class LambdaAbstractionRunner extends Runner
  constructor: (interpreter, @arg, @body, @name) ->
    super interpreter
  run: (thunk) ->
    i = @interpreter.createChild()
    i.env[@arg] = thunk
    return @body.accept i
  toString: ->
    @name or "\\#{@arg}.#{@body.accept toStringVisitor}"

LambdaAbstractionRunner.runnerWithCode = (code) ->
  ast = parser.parse(tokenizer.tokenize code).exprs[0]
  return Runner.create unless ast.tag is AST.LAMBDA_ABSTRACTION
  return {
    createMyself: (interpreter, name) ->
      return LambdaAbstractionRunner.create interpreter, ast.arg, ast.body, name
  }
