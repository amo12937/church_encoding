"use strict"

tokenizer = require "tokenizer"
parser = require "parser"
interpreterProvider = require "visitor/interpreter"
require "runner/reserved"

reporter =
  report: console.log.bind console

interpreter = interpreterProvider.create()

window.addEventListener "load", ->
  $input = document.getElementById "input"
  $result = document.getElementById "result"
  compile = (code) ->
    console.time "tokenizer"
    lexer = tokenizer.tokenize code
    console.timeEnd "tokenizer"
    
    console.time "parser"
    result = parser.parse lexer
    console.timeEnd "parser"

    console.time "interpreter"
    reporter.report result.accept interpreter
    console.timeEnd "interpreter"

  $input.addEventListener "change", ->
    compile $input.value

