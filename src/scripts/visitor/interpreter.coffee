"use strict"

AST = require "AST"
FutureEval = require "future_eval"
EnvManager = require "env_manager"
CREATE_CHILD_KEY = EnvManager.CREATE_CHILD_KEY
envManager = EnvManager.create()

Visitor = require "visitor/visitor"
runnerFactory = require "runner/factory"

module.exports = class Interpreter extends Visitor
  constructor: (@env = envManager.getGlobal()) -> undefined
  createChild: ->
    new Interpreter @env[CREATE_CHILD_KEY]()

Interpreter.create = (env = envManager.getGlobal()) ->
  Visitor.create.call @, env

Interpreter.registerVisit AST.LIST, (node) ->
  self = @
  return node.exprs.map((expr) -> "#{expr.accept self}").join "\n"

Interpreter.registerVisit AST.APPLICATION, (node) ->
  node.left.accept(@).run FutureEval.create node.right, @

Interpreter.registerVisit AST.LAMBDA_ABSTRACTION, (node) ->
  runnerFactory.create "LAMBDA_ABSTRACTION", @, node.arg, node.body

Interpreter.registerVisit AST.DEFINITION, (node) ->
  @env[node.name] = FutureEval.create node.body, @
  runnerFactory.create "DEFINITION", @, node.name, node.body

Interpreter.registerVisit AST.IDENTIFIER, (node) ->
  @env[node.name]?.get() or runnerFactory.create "IDENTIFIER", @, node.name

Interpreter.registerVisit AST.NUMBER.NATURAL, (node) ->
  runnerFactory.create "NUMBER", @, node.value

Interpreter.registerVisit AST.STRING, (node) ->
  runnerFactory.create "STRING", @, node.text

