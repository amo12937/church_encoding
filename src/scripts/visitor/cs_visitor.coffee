"use strict"

AST = require "AST"

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
      res = res.split("%body%").join template.split("%arg%").join id.value
    return res.split("%body%").join node.body.accept self

  visit[AST.DEFINITION] = (node) ->
    return "#{node.token.value} = #{node.body.accept self}"

  visit[AST.IDENTIFIER] = (node) ->
    return node.token.value

  return self
