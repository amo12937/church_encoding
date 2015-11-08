"use strict"

exports.CHILD_ENV_KEY = CEK = ">" # ID として指定できないものならなんでも良い

exports.create = ->
  Env = -> undefined

  global = new Env
  current = global

  Env.prototype[CEK] = (f) ->
    old = current
    Env.prototype = @
    current = new Env
    result = f current
    current = old
    return result

  getCurrent: -> current

