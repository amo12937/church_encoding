"use strict"

AST = require "AST"

exports.create = ->
  visit = {}
  self = {visit}

  visit[AST.IDENTIFIER] = (node) ->
    node.token.value

  visit[AST.LAMBDA_ABSTRACTION] = (node) ->
    args: node.args.map (id) -> id.value
    body: node.body.accept self

  visit[AST.APPLICATION] = (node) ->
    node.args.map (expr) -> expr.accept self

  visit[AST.DEFINITION] = (node) ->
    name: node.token.value
    body: node.body.accept self
  return self

