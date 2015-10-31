"use strict"

tokenizer = require "tokenizer"
parser = require "parser"
visitorProvider = require "visitor/tree_view_visitor"
jsonVisitorProvider = require "visitor/json_visitor"
jsVisitorProvider = require "visitor/js_visitor"
examplesManager = require "examples"

reporter =
  report: console.log.bind console

visitor = visitorProvider.create reporter
jsVisitor = jsVisitorProvider.create()

createResultFragment = (d, tokens) ->
  $fragment = d.createDocumentFragment()
  tokens.forEach (token) ->
    $p = d.createElement "p"
    $p.textContent = JSON.stringify token
    $fragment.appendChild $p
  return $fragment

window.addEventListener "load", ->
  $examples = document.getElementById "examples"
  $input = document.getElementById "input"
  $result = document.getElementById "result"
  compile = (code) ->
    console.time "tokenizer"
    lexer = tokenizer code
    console.timeEnd "tokenizer"
    
    console.time "parser"
    results = parser.parse lexer
    console.timeEnd "parser"

    for expr in results
      expr.accept visitor

    $result.textContent = null
    $fragment = createResultFragment document, results.map (expr) -> expr.accept jsVisitor
    $result.appendChild $fragment

  do ->
    seed = $examples.getAttribute "data-seed"
    key = $examples.getAttribute "data-key"
    $fragment = examplesManager.createFragment document, seed, key, (example) ->
      $input.value = example
      compile example
    $examples.appendChild $fragment

  $input.addEventListener "change", ->
    compile $input.value

