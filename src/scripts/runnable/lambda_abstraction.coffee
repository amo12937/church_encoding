"use strict"

Runnable = require "runnable/runnable"

class LambdaAbstractionRunnable extends Runnable
  constructor: (node, @interpreter) ->
    super node
  run: (thunk) ->
    i = @interpreter.createChild()
    i.env[@node.arg] = thunk
    return @node.body.accept i
LambdaAbstractionRunnable.create = (node, interpreter) ->
  new LambdaAbstractionRunnable node, interpreter

module.exports = LambdaAbstractionRunnable
