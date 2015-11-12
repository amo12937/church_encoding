"use strict"

stdlib = require "visitor/stdlib"
IdentifierRunner = require "runner/identifier"
IdentifierRunner.setStdlib stdlib

require "runner/identifier/succ"
require "runner/identifier/pred"
#require "runner/bool"
#
#require "runner/symbol/plus"
