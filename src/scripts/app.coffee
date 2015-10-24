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
  $error = document.getElementById "error"

  $input.addEventListener "change", ->
    s = $input.value
    $result.textContent = null
    $error.textContent = null
    tokenizer s
      .then (tokens) ->
        $fragment = createResultFragment document, tokens
        $result.appendChild $fragment
      .catch (e) ->
        $error.textContent = e

    

