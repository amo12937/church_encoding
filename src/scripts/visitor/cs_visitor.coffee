"use strict"

AST = require "AST"
{JS_KEYWORDS, CS_KEYWORDS} = require "constant"
NUMBER = "0123456789"

normalizeIdentifier = (s) ->
  return "$#{s}" if JS_KEYWORDS[s]? or CS_KEYWORDS[s]? or NUMBER[s[0]]?
  return s

exports.create = ->
  visit = {}
  self = {visit}

  visit[AST.APPLICATION] = (node) ->
    [first, others...] = node.exprs
    s = first.accept self
    return s if others.length is 0
    return others.reduce ((p, c) -> "(#{p})(#{c.accept self})"), s

  visit[AST.LAMBDA_ABSTRACTION] = (node) ->
    template = "(%arg%) -> %body%"
    res = "%body%"
    node.args.forEach (id) ->
      res = res.split("%body%").join template.split("%arg%").join normalizeIdentifier id.value
    return res.split("%body%").join node.body.accept self

  visit[AST.DEFINITION] = (node) ->
    return "#{normalizeIdentifier node.token.value} = #{node.body.accept self}"

  visit[AST.IDENTIFIER] = (node) ->
    return normalizeIdentifier node.token.value

  return self
