"use strict"

AST = require "AST"

separator = (l, r) ->
  return "" if l[l.length - 1] in ")}]" or r[0] in "({["
  return " "

exports.create = ->
  visit = {}
  self = {visit}

  visit[AST.LIST] = (node) ->
    node.exprs.map((expr) -> expr.accept self).join ""

  visit[AST.APPLICATION] = (node) ->
    l = node.left.accept self
    r = node.right.accept self
    return "(#{l}#{separator l, r}#{r})"

  visit[AST.LAMBDA_ABSTRACTION] = (node) ->
    l = node.arg
    r = node.body.accept self
    return "{#{l}#{separator l, r}#{r}}"

  visit[AST.DEFINITION] = (node) ->
    l = node.name
    r = node.body.accept self
    return "[#{l}#{separator l, r}#{r}]"

  visit[AST.IDENTIFIER] = (node) -> node.name
  visit[AST.NUMBER.NATURAL] = (node) -> "#{node.value}"
  visit[AST.STRING] = (node) -> node.value

  return self
