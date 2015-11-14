"use strict"

tokenizer = require "tokenizer"
parser = require "parser"
interpreterProvider = require "visitor/interpreter"
require "runner/reserved"

createFragment = (d, cls, items) ->
  $fragment = d.createDocumentFragment()
  for item in items when item.trim() isnt ""
    $fragment.appendChild createP d, cls, item
  return $fragment

createP = (d, cls, text) ->
  $p = d.createElement "p"
  $p.textContent = text
  $p.classList.add cls
  return $p

Reporter = (d, $result) ->
  code:
    report: (code) ->
      $result.appendChild createFragment d, "ce-out-code", code.split "\n"
  result:
    report: (result) ->
      $result.appendChild createFragment d, "ce-out-result", result.split "\n"

interpreter = interpreterProvider.create()

window.addEventListener "load", ->
  $input = document.getElementById "input"
  $result = document.getElementById "result"
  reporter = Reporter document, $result
  i = 0
  compile = (code) ->
    reporter.code.report code
    console.log "[#{i}] code ="
    console.log code
    console.time "[#{i}] tokenizer"
    lexer = tokenizer.tokenize code
    console.timeEnd "[#{i}] tokenizer"
    
    console.time "[#{i}] parser"
    result = parser.parse lexer
    console.timeEnd "[#{i}] parser"

    console.time "[#{i}] interpreter"
    reporter.result.report result.accept interpreter
    console.timeEnd "[#{i}] interpreter"

    i += 1

  $input.addEventListener "keypress", (e) ->
    return unless e.keyCode is 13
    return if e.shiftKey
    compile $input.value
    $input.value = ""
    e.preventDefault()

