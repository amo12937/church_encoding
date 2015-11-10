"use strict"

toStringVisitor = require("visitor/to_string_visitor").create()

class Runnable
  constructor: (@node) -> undefined
  run: (thunk) -> thunk.get()
  toString: -> @node.accept toStringVisitor
Runnable.create = (node) -> new @ node

module.exports = Runnable
