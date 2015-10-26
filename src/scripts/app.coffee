"use strict"

tokenizer = require "tokenizer"
parser = require "parser"
visitorProvider = require "tree_view_visitor"

reporter =
  report: console.log.bind console

visitor = visitorProvider.create reporter

createResultFragment = (d, tokens) ->
  $fragment = d.createDocumentFragment()
  tokens.forEach (token) ->
    $p = d.createElement "p"
    $p.textContent = JSON.stringify token
    $fragment.appendChild $p
  return $fragment

window.addEventListener "load", ->
  $input = document.getElementById "input"
  $result = document.getElementById "result"

  $input.addEventListener "change", ->
    s = $input.value
#    $result.textContent = null
    console.time "tokenizer"
    lexer = tokenizer s
    console.timeEnd "tokenizer"
    
    console.time "parser"
    results = parser.parse lexer
    console.timeEnd "parser"

    for expr in results
      expr.accept visitor

#    $fragment = createResultFragment document, tokens
#    $result.appendChild $fragment

