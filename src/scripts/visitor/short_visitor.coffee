"use strict"

AST = require "AST"
Visitor = require "visitor/visitor"

separator = (l, r) ->
  return "" if l[l.length - 1] in ")}]" or r[0] in "({["
  return " "

module.exports = class ShortVisitor extends Visitor

ShortVisitor.registerVisit AST.LIST, (node) ->
  self = @
  node.exprs.map((expr) -> expr.accept self).join ""

ShortVisitor.registerVisit AST.APPLICATION, (node) ->
  l = node.left.accept @
  r = node.right.accept @
  return "(#{l}#{separator l, r}#{r})"

ShortVisitor.registerVisit AST.LAMBDA_ABSTRACTION, (node) ->
  l = node.arg
  r = node.body.accept @
  return "{#{l}#{separator l, r}#{r}}"

ShortVisitor.registerVisit AST.DEFINITION, (node) ->
  l = node.name
  r = node.body.accept @
  return "[#{l}#{separator l, r}#{r}]"

ShortVisitor.registerVisit AST.IDENTIFIER, (node) -> node.name
ShortVisitor.registerVisit AST.NUMBER.NATURAL, (node) -> "#{node.value}"
ShortVisitor.registerVisit AST.STRING, (node) -> node.value

