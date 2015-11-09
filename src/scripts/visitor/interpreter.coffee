"use strict"

AST = require "AST"
FutureEval = require "future_eval"
EnvManager = require("env_manager")
CREATE_CHILD_KEY = EnvManager.CREATE_CHILD_KEY
envManager = EnvManager.create()
toStringVisitor = require("visitor/to_string_visitor").create()

class Applicable
  constructor: (@apply) -> undefined

class Lambda extends Applicable
  constructor: (@env, @args, @body) ->
    super (x) ->
      [arg, others...] = @args
      e = @env[CREATE_CHILD_KEY]()
      e[arg] = x
      v = createVisitor e
      return @body.accept v if others.length is 0
      return Lambda.create e, others, @body
  toString: ->
    a = @args.join " "
    b = @body.accept toStringVisitor
    "(\\#{a}.#{b})"
Lambda.create = (env, args, body) -> new Lambda env, args, body

class Definition extends Applicable
  constructor: (@node) ->
    super (x) -> x
  toString: ->
    @node.accept toStringVisitor
Definition.create = (node) -> new Definition node

createVisitor = (env) ->
  visit = {}
  self = {visit}

  visit[AST.LIST] = (node) ->
    res = null
    for expr in node.exprs
      res = expr.accept self # 最後の結果だけを返す
    return res

  visitApp = (exprs) ->
    if exprs.length is 1
      return exprs[0].accept self
    [lefts..., right] = exprs
    left = visitApp lefts
  
    if left instanceof Applicable
      return left.apply FutureEval.create right, self
    return "#{left} #{right.accept toStringVisitor}" # これ以上簡約できない

  visit[AST.APPLICATION] = (node) ->
    visitApp node.exprs

  visit[AST.LAMBDA_ABSTRACTION] = (node) ->
    args = node.args.map (id) -> id.value
    return Lambda.create env, args, node.body

  visit[AST.DEFINITION] = (node) ->
    name = node.token.value
    env[name] = FutureEval.create node.body, self
    return Definition.create node

  visit[AST.IDENTIFIER] = (node) ->
    return env[node.token.value]?.get() or node.accept toStringVisitor # これ以上簡約できない

  self.run = (ast) -> "#{ast.accept self}"

  return self

exports.create = (env = envManager.getGlobal()) ->
  return createVisitor env

