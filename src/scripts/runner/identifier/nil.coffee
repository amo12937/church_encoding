"use strict"

IdentifierRunner = require "runner/identifier"

module.exports = class NilIdentifierRunner extends IdentifierRunner
  run: (thunk) -> @
IdentifierRunner.register "nil", NilIdentifierRunner

