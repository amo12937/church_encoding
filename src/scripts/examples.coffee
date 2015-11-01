"use strict"

module.exports = [
  [ 0, "p0     := \\f x.x",                                   ["p0 = (f) -> (x) -> x"]]
  [ 1, "p1     := \\f x.f x",                                 ["p1 = (f) -> (x) -> (f)(x)"]]
  [ 2, "p2     := \\f x.f (f x)",                             ["p2 = (f) -> (x) -> (f)((f)(x))"]]
  [ 3, "succ   := \\n f x.f (n f x)",                         ["succ = (n) -> (f) -> (x) -> (f)(((n)(f))(x))"]]
  [ 4, "pred   := \\n f x.n (\\g h.h (g f)) (\\u.x) (\\v.v)", ["pred = (n) -> (f) -> (x) -> (((n)((g) -> (h) -> (h)((g)(f))))((u) -> x))((v) -> v)"]]
  [ 5, "true   := \\x y.x",                                   ["true = (x) -> (y) -> x"]]
  [ 6, "false  := \\x y.y",                                   ["false = (x) -> (y) -> y"]]
  [ 7, "and    := \\p q x y.p (q x y) y",                     ["and = (p) -> (q) -> (x) -> (y) -> ((p)(((q)(x))(y)))(y)"]]
  [ 8, "or     := \\p q x y.p x (q x y)",                     ["or = (p) -> (q) -> (x) -> (y) -> ((p)(x))(((q)(x))(y))"]]
  [ 9, "not    := \\p x y.p y x",                             ["not = (p) -> (x) -> (y) -> ((p)(y))(x)"]]
  [10, "pair   := \\a b p.p a b",                             ["pair = (a) -> (b) -> (p) -> ((p)(a))(b)"]]
  [11, "first  := \\p.p true",                                ["first = (p) -> (p)(true)"]]
  [12, "second := \\p.p false",                               ["second = (p) -> (p)(false)"]]
  [13, "Y      := \\f.(\\x.f (x x)) (\\x.f (x x))",           ["Y = (f) -> ((x) -> (f)((x)(x)))((x) -> (f)((x)(x)))"]]
]

