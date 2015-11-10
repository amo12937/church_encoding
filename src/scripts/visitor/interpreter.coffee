"use strict"

AST = require "AST"
FutureEval = require "future_eval"
EnvManager = require "env_manager"
CREATE_CHILD_KEY = EnvManager.CREATE_CHILD_KEY
envManager = EnvManager.create()

Runner = require "runner/runner"
LambdaAbstractionRunner = require "runner/lambda_abstraction"
DefinitionRunner = require "runner/definition"
IdentifierRunner = require "runner/identifier"
NumberRunner = require "runner/number"
require "runner/reserved"

exports.create = createInterpreter = (env = envManager.getGlobal()) ->
  visit = {}
  self =
    env: env
    visit: visit
    createChild: -> createInterpreter env[CREATE_CHILD_KEY]()

  visit[AST.LIST] = (node) ->
    return node.exprs.map((expr) -> "#{expr.accept self}").join "\n"

  visit[AST.APPLICATION] = (node) ->
    node.left.accept(self).run FutureEval.create node.right, self

  visit[AST.LAMBDA_ABSTRACTION] = (node) ->
    LambdaAbstractionRunner.create self, node.arg, node.body

  visit[AST.DEFINITION] = (node) ->
    env[node.name] = FutureEval.create node.body, self
    return DefinitionRunner.create self, node.name, node.body

  visit[AST.IDENTIFIER] = (node) ->
    return env[node.name]?.get() or IdentifierRunner.create self, node.name

  visit[AST.NUMBER.NATURAL] = (node) ->
    return NumberRunner.create self, node.value

  return self
