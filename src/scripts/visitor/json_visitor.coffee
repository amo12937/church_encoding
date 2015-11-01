"use strict"

AST = require "AST"

exports.create = ->
  visit = {}
  self = {visit}

  visit[AST.APPLICATION] = (node) ->
    node.exprs.map (expr) -> expr.accept self

  visit[AST.LAMBDA_ABSTRACTION] = (node) ->
    args: node.args.map (id) -> id.value
    body: node.body.accept self

  visit[AST.DEFINITION] = (node) ->
    name: node.token.value
    body: node.body.accept self

  visit[AST.IDENTIFIER] = (node) ->
    node.token.value

  return self
