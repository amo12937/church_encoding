"use strict"

AST = require "AST"
Interpreter = require "visitor/interpreter"

EnvManager = require "env_manager"
CREATE_CHILD_KEY = EnvManager.CREATE_CHILD_KEY
envManager = EnvManager.create()
global = envManager.getGlobal()
stdlibEnv = global[CREATE_CHILD_KEY]()
stdlibEnv[CREATE_CHILD_KEY] = ->
  global[CREATE_CHILD_KEY]()

runnerFactory = require("runner/factory")

class Stdlib extends Interpreter

Stdlib.registerVisit AST.IDENTIFIER, (node) ->
  return runnerFactory.create "IDENTIFIER", @, node.name

module.exports = stdlib = Stdlib.create stdlibEnv

tokenizer = require "tokenizer"
parser = require "parser"

codes = [
  "succ   := \\n f x.f (n f x)"
  "pred   := \\n f x.n (\\g h.h (g f)) (\\u.x) (\\v.v)"
  "+      := \\m n f x.m f (n f x)"
  "*      := \\m n f.m (n f)"
  "sub    := \\m n.n pred m"
  "div    := \\n.Y (\\f q m n.(s := sub m n) isZero s q (f (succ q) s n)) 0 (succ n)"

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
  "list   := Y (\\f A m.isnil m (A m) (f (\\x.A (cons m x)))) (\\u.u)"

  "Y      := \\f.(\\x.f (x x)) (\\x.f (x x))"
  "K      := \\x y.x"
  "S      := \\x y z.x z (y z)"
  "I      := \\x.x"
  "X      := \\x.x S K"
  "fact   := Y (\\f r n.isZero n r (f (* r n) (pred n))) 1"
]

parser.parse(tokenizer.tokenize codes.join "\n").accept stdlib

