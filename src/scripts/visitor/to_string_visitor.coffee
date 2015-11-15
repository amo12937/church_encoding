"use strict"

AST = require "AST"
Visitor = require "visitor/visitor"

module.exports = class ToStringVisitor extends Visitor

ToStringVisitor.registerVisit AST.LIST, (node) ->
  self = @
  node.exprs.map((expr) -> expr.accept self).join "\n"

ToStringVisitor.registerVisit AST.APPLICATION, (node) ->
  "(#{node.left.accept @} #{node.right.accept @})"

ToStringVisitor.registerVisit AST.LAMBDA_ABSTRACTION, (node) ->
  "(\\#{node.arg}.#{node.body.accept @})"

ToStringVisitor.registerVisit AST.DEFINITION, (node) ->
  "(#{node.name} := #{node.body.accept @})"

ToStringVisitor.registerVisit AST.IDENTIFIER, (node) -> node.name

ToStringVisitor.registerVisit AST.NUMBER.NATURAL, (node) -> node.value

ToStringVisitor.registerVisit AST.STRING, (node) -> node.value

