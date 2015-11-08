"use strict"

AST = require "AST"
envManagerProvider = require "env_manager"

class Lambda
  constructor: (@run) -> undefined
Lambda.create = (func) -> new Lambda func

class Application
  constructor: (@left, @right) -> undefined
Application.create = (left, right) -> new Application left, right

exports.create = (reporter) ->
  visit = {}
  self = {visit}

  envManager = envManagerProvider.create()
  CHILD_ENV_KEY = envManagerProvider.CHILD_ENV_KEY

  self.run = (ast) ->
    reporter.report ast.accept self
    
  visit[AST.LIST] = (node) ->
    res = null
    for expr in node.exprs
      res = expr.accept self # 最後の結果だけを返す
    return res

  visitApp = (exprs, env) ->
    if exprs.length is 1
      return exprs[0].accept self
    [lefts..., right] = exprs
    left = visitApp lefts, env
    if left instanceof Lambda
      return left.run right.accept self
    return Application.create left, right

  visit[AST.APPLICATION] = (node) ->
    env = envManager.getCurrent()
    return visitApp node.exprs, env

  visitLambda = (args, body, env) ->
    [arg, others...] = args
    i = 0
    return Lambda.create (x) ->
      env[CHILD_ENV_KEY] (local) ->
        local[arg] = x
        return body.accept self if others.length is 0
        return visitLambda others, body, local

  visit[AST.LAMBDA_ABSTRACTION] = (node) ->
    args = node.args.map (id) -> id.value
    env = envManager.getCurrent()
    return visitLambda args, node.body, env
  
  visit[AST.DEFINITION] = (node) ->
    name = node.token.value
    body = node.body.accept self
    env = envManager.getCurrent()
    env[name] = body
    return Lambda.create (x) -> x

  visit[AST.IDENTIFIER] = (node) ->
    id = node.token.value
    env = envManager.getCurrent()
    return env[id] or id

  return self

