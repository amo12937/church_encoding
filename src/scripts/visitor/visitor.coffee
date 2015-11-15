"use strict"

AST = require "AST"

module.exports = class Visitor
  constructor: -> undefined
  visit: (node) ->
    @["visit_#{node.tag}"] node

Visitor.registerVisit = (tag, func) ->
  @prototype["visit_#{tag}"] = func

Visitor.create = ->
  new (Function.prototype.bind.apply @, [@, arguments...])

