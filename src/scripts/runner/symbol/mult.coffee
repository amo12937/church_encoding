"use strict"

IdentifierRunner = require "runner/identifier"
NumberRunner = require "runner/number"
BradeRunner = require "runner/brade"

module.exports = class MultSymbolRunner extends IdentifierRunner
  run: (mThunk) ->
    i = @interpreter
    name = @name
    toS = -> "\\n f.m (n f)"
    return BradeRunner.create i, toS, (nThunk) ->
      m = mThunk.get()
      n = nThunk.get()
      if m instanceof NumberRunner and n instanceof NumberRunner
        return NumberRunner.create i, m.value * n.value
      return i.env[name]?.get().run(mThunk).run(nThunk)
IdentifierRunner.register "*", MultSymbolRunner

