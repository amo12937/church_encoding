"use strict"

AST = require "AST"

exports.create = ->
  visit = {}
  self = {visit}

  visit[AST.IDENTIFIER] = (node) ->
    return node.token.value

  visit[AST.LAMBDA_ABSTRACTION] = (node) ->
    template = "function (%arg%) { return (%body%); }"
    res = "%body%"
    node.args.forEach (id) ->
      res = res.split("%body%").join template.split("%arg%").join id.value
    return res.split("%body%").join node.body.accept self

  visit[AST.APPLICATION] = (node) ->
    res = node.args.reduce ((p, c) -> "(#{p})(#{c.accept self})"), "\\dummy\\"
    return res.split("(\\dummy\\)").join ""

  visit[AST.DEFINITION] = (node) ->
    return "var #{node.token.value} = (#{node.body.accept self});"
  return self
