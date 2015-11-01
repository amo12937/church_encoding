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

  visit[AST.APPLICATION] = (node) ->
    puts AST.APPLICATION
    indent -> expr.accept self for expr in node.exprs

  visit[AST.LAMBDA_ABSTRACTION] = (node) ->
    puts AST.LAMBDA_ABSTRACTION

    indent ->
      puts "arguments:"
      indent -> puts id.value for id in node.args
         
      puts "body:"
      indent -> node.body.accept self

  visit[AST.DEFINITION] = (node) ->
    puts AST.DEFINITION
    indent ->
      puts "name:"
      indent -> puts node.token.value

      puts "body:"
      indent -> node.body.accept self
       
  visit[AST.IDENTIFIER] = (node) ->
    puts AST.IDENTIFIER
    indent -> puts node.token.value

  return self
