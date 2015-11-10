"use strict"

AST = require "AST"
FutureEval = require "future_eval"
EnvManager = require "env_manager"
CREATE_CHILD_KEY = EnvManager.CREATE_CHILD_KEY
envManager = EnvManager.create()

Runnable = require "runnable/runnable"
LambdaAbstractionRunnable = require "runnable/lambda_abstraction"

exports.create = createInterpreter = (env = envManager.getGlobal()) ->
  visit = {}
  self =
    env: env
    visit: visit
    createChild: -> createInterpreter env[CREATE_CHILD_KEY]()

  visit[AST.LIST] = (node) ->
    res = null
    for expr in node.exprs
      res = expr.accept self # 最後の結果だけを返す
    return "#{res}"

  visit[AST.APPLICATION] = (node) ->
    node.left.accept(self).run FutureEval.create node.right, self

  visit[AST.LAMBDA_ABSTRACTION] = (node) ->
    LambdaAbstractionRunnable.create node, self

  visit[AST.DEFINITION] = (node) ->
    env[node.name] = FutureEval.create node.body, self
    return Runnable.create node

  visit[AST.IDENTIFIER] = (node) ->
    return env[node.name]?.get() or Runnable.create node

  return self
