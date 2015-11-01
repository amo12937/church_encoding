"use strict"

examples = require "examples"
exports.createFragment = (d, seed, key, click) ->
  $fragment = d.createDocumentFragment()
  for example in examples
    $div = d.createElement "div"
    $div.innerHTML = seed.split(key).join example[1]
    $div.addEventListener "click", do (code = example[1]) -> ->
      click code
    $fragment.appendChild $div
  return $fragment
