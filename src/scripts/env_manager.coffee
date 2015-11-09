"use strict"

exports.CREATE_CHILD_KEY = CCK = "<" # ID として指定できないものならなんでも良い

exports.create = ->
  Env = -> undefined
  global = new Env

  Env.prototype[CCK] = ->
    Env.prototype = @
    return new Env

  getGlobal: -> global
