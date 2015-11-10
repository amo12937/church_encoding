"use strict"

AST = require "AST"
exports.create = ->
  visit = {}
  self = {visit}

  visit[AST.LIST] = (node) ->
    node.exprs.map((expr) -> expr.accept self).join "\n"

  visit[AST.APPLICATION] = (node) ->
    "(#{node.left.accept self} #{node.right.accept self})"

  visit[AST.LAMBDA_ABSTRACTION] = (node) ->
    "(\\#{node.arg}.#{node.body.accept self})"

  visit[AST.DEFINITION] = (node) ->
    "(#{node.name} := #{node.body.accept self})"

  visit[AST.IDENTIFIER] = (node) ->
    node.name

  return self

