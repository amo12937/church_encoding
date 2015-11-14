"use strict"

AST = require "AST"

exports.create = ->
  visit = {}
  self = {visit}

  visit[AST.LIST] = (node) ->
    node.exprs.map (expr) -> expr.accept self

  visit[AST.APPLICATION] = (node) ->
    left: node.left.accept self
    right: node.right.accept self

  visit[AST.LAMBDA_ABSTRACTION] = (node) ->
    arg: node.arg
    body: node.body.accept self

  visit[AST.DEFINITION] = (node) ->
    name: node.name
    body: node.body.accept self

  visit[AST.IDENTIFIER] = (node) ->
    node.name

  visit[AST.NUMBER.NATURAL] = (node) ->
    node.value

  visit[AST.STRING] = (node) ->
    node.value

  return self
