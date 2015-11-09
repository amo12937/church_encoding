"use strict"

exports.create = (node, visitor) ->
  resolved = null
  get: ->
    resolved ?= node.accept visitor
