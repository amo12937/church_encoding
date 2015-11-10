"use strict"

exports.create = (node, visitor) ->
  @createWithGetter -> node.accept visitor

exports.createWithGetter = (getter) ->
  resolved = null
  get: ->
    resolved ?= getter()

