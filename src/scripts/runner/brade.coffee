"use strict"

Runner = require "runner/runner"

module.exports = class BradeRunner extends Runner
  constructor: (interpreter, @toString, @run) -> undefined

