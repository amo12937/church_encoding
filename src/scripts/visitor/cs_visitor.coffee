"use strict"

AST = require "AST"
{JS_KEYWORDS, CS_KEYWORDS} = require "constant"
NUMBER = "0123456789"

normalizeIdentifier = (s) ->
  return "$#{s}" if JS_KEYWORDS[s]? or CS_KEYWORDS[s]?
  return s

exports.create = ->
  visit = {}
  self = {visit}

  visit[AST.LIST] = (node) ->
    node.exprs.map((expr) -> expr.accept self).join "\n"

  visit[AST.APPLICATION] = (node) ->
    "(#{node.left.accept self})(#{node.right.accept self})"

  visit[AST.LAMBDA_ABSTRACTION] = (node) ->
    "(#{node.arg}) -> #{node.body.accept self}"

  visit[AST.DEFINITION] = (node) ->
    "#{normalizeIdentifier node.name} = #{node.body.accept self}"

  visit[AST.IDENTIFIER] = (node) ->
    normalizeIdentifier node.name

  visit[AST.NUMBER.NATURAL] = (node) ->
    "$_#{node.value}"

  return self
