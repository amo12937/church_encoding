"use strict"

examples = [
  "p0     := \\f x.x"
  "p1     := \\f x.f x"
  "p2     := \\f x.f (f x)"
  "succ   := \\n f x.f (n f x)"
  "pred   := \\n f x.n (\\g h.h (g f)) (\\u.x) (\\v.v)"
  "true   := \\x y.x"
  "false  := \\x y.y"
  "and    := \\p q x y.p (q x y) y"
  "or     := \\p q x y.p x (q x y)"
  "not    := \\p x y.p y x"
  "pair   := \\a b p.p a b"
  "first  := \\p.p true"
  "second := \\p.p false"
  "Y      := \\f.(\\x.f (x x)) (\\x.f (x x))"
]

exports.createFragment = (d, seed, key, click) ->
  $fragment = d.createDocumentFragment()
  for example in examples
    $div = d.createElement "div"
    $div.innerHTML = seed.split(key).join example
    $div.addEventListener "click", do (code = example) -> ->
      click code
    $fragment.appendChild $div
  return $fragment

