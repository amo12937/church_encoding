"use strict"

AST = require "AST"
{JS_KEYWORDS} = require "constant"
NUMBER = "0123456789"

normalizeIdentifier = (s) ->
  return "$#{s}" if JS_KEYWORDS[s]?
  return "$_#{s}" if NUMBER[s[0]]?
  return s

exports.create = ->
  visit = {}
  self = {visit}

  visit[AST.LIST] = (node) ->
    node.exprs.map((expr) -> expr.accept self).join "\n"

  visit[AST.APPLICATION] = (node) ->
    "(#{node.left.accept self})(#{node.right.accept self})"

  visit[AST.LAMBDA_ABSTRACTION] = (node) ->
    "function(#{node.arg}) { return #{node.body.accept self}; }"

  visit[AST.DEFINITION] = (node) ->
    "var #{normalizeIdentifier node.name} = #{node.body.accept self};"

  visit[AST.IDENTIFIER] = (node) ->
    normalizeIdentifier node.name

  return self
