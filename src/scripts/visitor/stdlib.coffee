"use strict"

Interpreter = require "visitor/interpreter"
envManager = require("env_manager").create()
tokenizer = require "tokenizer"
parser = require "parser"

module.exports = stdlib = Interpreter.create envManager.getGlobal()

codes = [
  "succ   := \\n f x.f (n f x)"
  "pred   := \\n f x.n (\\g h.h (g f)) (\\u.x) (\\v.v)"
  "+      := \\m n f x.m f (n f x)"
  "*      := \\m n f.m (n f)"

  "true   := \\x y.x"
  "false  := \\x y.y"
  "and    := \\p q.p q false"
  "or     := \\p q.p true q"
  "not    := \\p x y.p y x"
  "if     := \\p x y.p x y"
  "isZero := \\n.n (\\x.false) true"
  "pair   := \\a b p.p a b"
  "first  := \\p.p true"
  "second := \\p.p false"

  "cons   := pair"
  "head   := first"
  "tail   := second"

  "Y      := \\f.(\\x.f (x x)) (\\x.f (x x))"
  "K      := \\x y.x"
  "S      := \\x y z.x z (y z)"
  "I      := \\x.x"
  "X      := \\x.x S K"
  "fact   := \\f n.if (isZero n) 1 (* n (f (pred n)))"
]

parser.parse(tokenizer.tokenize codes.join "\n").accept stdlib


