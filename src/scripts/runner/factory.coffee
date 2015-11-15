"use strict"

class RunnerFactory
  constructor: ->
    @runners = {}

  create: ->
    [name, args...] = arguments
    @runners[name].apply @, args

  register: (name, func) ->
    @runners[name] = func

module.exports = runnerFactory = new RunnerFactory

