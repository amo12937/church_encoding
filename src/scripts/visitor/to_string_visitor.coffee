"use strict"

AST = require "AST"
exports.create = ->
  visit = {}
  self = {visit}

  visit[AST.LIST] = (node) ->
    node.exprs.map((expr) -> expr.accept self).join "\n"

  visit[AST.APPLICATION] = (node) ->
    return node.exprs[0].accept self if node.exprs.length is 1
    tmp = node.exprs.map((expr) -> "#{expr.accept self}").join " "
    return "(#{tmp})"

  visit[AST.LAMBDA_ABSTRACTION] = (node) ->
    args = node.args.map((id) -> id.value).join " "
    body = node.body.accept self
    return "(\\#{args}.#{body})"

  visit[AST.DEFINITION] = (node) ->
    return "#{node.token.value} := #{node.body.accept self}"

  visit[AST.IDENTIFIER] = (node) ->
    return node.token.value

  return self

