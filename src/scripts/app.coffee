"use strict"

tokenizer = require "tokenizer"

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
    $result.textContent = null
    tokens = tokenizer s
    $fragment = createResultFragment document, tokens
    $result.appendChild $fragment

