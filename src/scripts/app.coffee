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
  error:
    report: (errors) ->
      $result.appendChild createFragment d, "ce-out-error", errors
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
    i += 1
    
    reporter.code.report code
    console.log "[#{i}] code ="
    console.log code
    errors = []
    console.time "[#{i}] tokenizer"
    lexer = tokenizer.tokenize code, errors
    console.timeEnd "[#{i}] tokenizer"

    if errors.length > 0
      reporter.error.report errors.map (error) ->
        "#{error.tag}[#{error.line} : #{error.column}]: #{error.value}"
      return
    
    errors = []
    console.time "[#{i}] parser"
    pResult = parser.parse lexer, errors
    console.timeEnd "[#{i}] parser"
    if errors.length > 0
      reporter.error.report errors.map (error) ->
        "#{error.name}[#{error.token.line} : #{error.token.column}]: #{error.token.value} (tokenTag = #{error.token.tag})"
      return

    console.time "[#{i}] interpreter"
    try
      reporter.result.report pResult.accept interpreter
    catch e
      reporter.error.report ["RUNTIME_ERROR: #{e.message}"]
    console.timeEnd "[#{i}] interpreter"

  $input.addEventListener "keypress", (e) ->
    return unless e.keyCode is 13
    return if e.shiftKey
    e.preventDefault()
    s = $input.value.trim()
    return if s is ""
    compile s
    $input.value = ""

