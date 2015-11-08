"use strict"

tokenizer = require "tokenizer"
parser = require "parser"
visitorProvider = require "visitor/tree_view_visitor"
jsVisitorProvider = require "visitor/js_visitor"
toStringVisitorProvider = require "visitor/to_string_visitor"
examplesAppender = require "views/append_examples"

reporter =
  report: console.log.bind console

visitor = visitorProvider.create reporter
jsVisitor = jsVisitorProvider.create()
toStringVisitor = toStringVisitorProvider.create()

createResultFragment = (d, results) ->
  $fragment = d.createDocumentFragment()
  results.forEach (result) ->
    $p = d.createElement "p"
    $p.textContent = result
    $fragment.appendChild $p
  return $fragment

window.addEventListener "load", ->
  $examples = document.getElementById "examples"
  $input = document.getElementById "input"
  $result = document.getElementById "result"
  compile = (code) ->
    console.time "tokenizer"
    lexer = tokenizer.tokenize code
    console.timeEnd "tokenizer"
    
    console.time "parser"
    result = parser.parse lexer
    console.timeEnd "parser"

    result.accept visitor
    reporter.report result.accept toStringVisitor

    $result.textContent = null
    $fragment = createResultFragment document, result.accept jsVisitor
    $result.appendChild $fragment

  do ->
    seed = $examples.getAttribute "data-seed"
    key = $examples.getAttribute "data-key"
    $fragment = examplesAppender.createFragment document, seed, key, (example) ->
      $input.value = "#{($input.value or "").trim()}\n#{example}".trim()
      compile $input.value
    $examples.appendChild $fragment

  $input.addEventListener "change", ->
    compile $input.value

