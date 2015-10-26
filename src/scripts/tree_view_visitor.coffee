"use strict"

AST = require "AST"

create = (reporter, tab = "  ") ->
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

  visit[AST.IDENTIFIER] = (node) ->
    puts AST.IDENTIFIER
    indent ->
      puts node.token.value

  visit[AST.LAMBDA_ABSTRACTION] = (node) ->
    puts AST.LAMBDA_ABSTRACTION

    indent ->
      puts "arguments:"

      indent ->
        for id in node.args
          puts id.value

      puts "body:"
      indent ->
        node.body.accept self

  visit[AST.APPLICATION] = (node) ->
    puts AST.APPLICATION
    indent ->
      for expr in node.args
        expr.accept self

  visit[AST.DEFINITION] = (node) ->
    puts AST.DEFINITION
    indent ->
      puts "name:"
      indent ->
        puts node.token.value

      puts "body:"
      indent ->
        node.body.accept self

  return self
    
module.exports = {create}
