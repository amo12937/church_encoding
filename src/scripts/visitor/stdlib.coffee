"use strict"

Interpreter = require "visitor/interpreter"
envManager = require("env_manager").create()
tokenizer = require "tokenizer"
parser = require "parser"

module.exports = stdlib = Interpreter.create envManager.getGlobal()

codes = [
  "succ   := \\n f x.f (n f x)"
  "pred   := \\n f x.n (\\g h.h (g f)) (\\u.x) (\\v.v)"

  "true   := \\x y.x"
  "false  := \\x y.y"
  "and    := \\p q.p q false"
  "or     := \\p q.p true q"
  "isZero := \\n.n (\\x.false) true"
  "pair   := \\a b p.p a b"
  "first  := \\p.p true"
  "second := \\p.p false"
]

parser.parse(tokenizer.tokenize codes.join "\n").accept stdlib


