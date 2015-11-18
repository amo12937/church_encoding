"use strict"

stdlib = require "visitor/stdlib"

usage = [
  "help (BNF|application|lambda|definition|defined)"
]

s =
  BNF: [
    "S                    ::= (<application> '\\n')+"
    "<application>        ::= <expr>+"
    "<expr>               ::= '(' <application> ')'"
    "                      |  <lambda_abstraction>"
    "                      |  <definition>"
    "                      |  <constant>"
    "<lambda_abstraction> ::= '\\' <identifier>+ '.' <application>"
    "<definition>         ::= <identifier> ':=' <application>"
    "<constant>           ::= <identifier>"
    "                      |  <natural_number>"
    "                      |  <string>"
    "<identifier>         ::= /^(?:[_a-zA-Z]\\w*|[!$%&*+/<=>?@^|\\-~]+)$/"
    "<natural_number>     ::= /^(?:0|[1-9]\\d*)$/"
    "<string>             ::= /^(?:'((?:[^'\\\\]|\\\\.)*)'|'((?:[^'\\\\]|\\\\.)*)')/"
  ]
  
  application: [
    "<expr> <expr> <expr> ..."
    "ex:"
    "  succ 5"
    "  fact 5"
    "  sum (list 1 2 3 nil)"
  ]
  
  lambda: [
    "\\<arguments>.<body>"
    "ex:"
    "  \\f x.x"
    "  \\f x.f x"
    "  \\n f x.n (\\g h.h (g f)) (\\u.x) (\\v.v)"
  ]
  
  definition: [
    "<var> := <body>"
    "ex:"
    "  true := \\x y.x"
    "  false := \\x y.y"
    "  sum := Y (\\f r p.isnil p r (f (+ r (head p)) (tail p))) 0"
    "  pred := \\n f x.n (\\g h.h (g f)) (\\u.x) (\\v.v)"
  ]

  defined: stdlib.codes

module.exports = (key) ->
  s[key] or usage
