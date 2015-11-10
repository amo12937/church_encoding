"use strict"

AST = require "AST"

exports.create = (reporter, tab = "  ") ->
  depth = ""

  indent = (f) ->
    original = depth
    depth += tab
    f()
    depth = original

  puts = (s) ->
    reporter.report "#{depth}#{s}"
  
  visit = {}
  self = {visit: visit}

  visit[AST.LIST] = (node) ->
    for expr in node.exprs
      expr.accept self
    return

  visit[AST.APPLICATION] = (node) ->
  visit[AST.APPLICATION] = (node) ->
    puts AST.APPLICATION
    indent ->
      node.left.accept self
      node.right.accept self

  visit[AST.LAMBDA_ABSTRACTION] = (node) ->
    puts AST.LAMBDA_ABSTRACTION
    indent ->
      puts node.arg
      node.body.accept self

  visit[AST.DEFINITION] = (node) ->
    puts AST.DEFINITION
    indent ->
      puts node.name
      node.body.accept self
      
  visit[AST.IDENTIFIER] = (node) ->
    puts node.name

  return self
