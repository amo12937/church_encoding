"use strict"

chai = require "chai"
expect = chai.expect
sinon = require "sinon"
sinonChai = require "sinon-chai"
chai.use sinonChai

TOKEN = require "TOKEN"
tokenizer = require "tokenizer"
t = (tag, value, line, column) -> {tag, value, line, column}
eof = (line, column) -> t TOKEN.EOF, "", line, column
c = (a, e) ->
  expect(Object.keys(a).length).to.be.equal 4
  expect(a.tag   ).to.be.equal e.tag
  expect(a.value ).to.be.equal e.value
  expect(a.line  ).to.be.equal e.line
  expect(a.column).to.be.equal e.column

examples = [
  [ 0, "", [eof 0, 0]]
  [ 1, "# comment", [eof 0, 9]]
  [ 2, "# comment\n", [t(TOKEN.LINE_BREAK, "\n", 0, 9), eof(1, 0)]]
  [ 3, "#- comment -#", [eof(0, 13)]]
  [ 4, "#- - -#", [eof 0, 7]]
  [ 5, "#- # -#", [eof 0, 7]]
  [ 6, "#-#-#", [eof 0, 5]]
  [ 7, "#- \n\n\n -#", [eof(3, 3)]]
  [ 8, "     ", [eof 0, 5]]
  [ 9, "  \n  ", [t(TOKEN.LINE_BREAK, "\n", 0, 2), eof(1, 2)]]
  [10, "  \n  \n  \n  ", [t(TOKEN.LINE_BREAK, "\n", 0, 2), eof(3, 2)]]
  [11, "\\", [t(TOKEN.LAMBDA, "\\", 0, 0), eof(0, 1)]]
  [12, ".", [t(TOKEN.LAMBDA_BODY, ".", 0, 0), eof(0, 1)]]
  [13, "(", [t(TOKEN.BRACKETS_OPEN, "(", 0, 0), eof(0, 1)]]
  [14, ")", [t(TOKEN.ERROR.UNMATCHED_BRACKET, ")", 0, 0), eof(0, 1)]]
  [15, "()", [
    t(TOKEN.BRACKETS_OPEN, "(", 0, 0)
    t(TOKEN.BRACKETS_CLOSE, ")", 0, 1)
    eof(0, 2)
  ]]
  [16, "(\n)", [
    t(TOKEN.BRACKETS_OPEN, "(", 0, 0)
    t(TOKEN.BRACKETS_CLOSE, ")", 1, 0)
    eof(1, 1)
  ]]
  [17, ":=", [t(TOKEN.DEF_OP, ":=", 0, 0), eof(0, 2)]]
  [18, "hoge", [t(TOKEN.IDENTIFIER, "hoge", 0, 0), eof(0, 4)]]
  [19, "h_ge", [t(TOKEN.IDENTIFIER, "h_ge", 0, 0), eof(0, 4)]]
  [20, "1234", [t(TOKEN.IDENTIFIER, "1234", 0, 0), eof(0, 4)]]
  [21, "1_34", [t(TOKEN.IDENTIFIER, "1_34", 0, 0), eof(0, 4)]]
  [22, "____", [t(TOKEN.IDENTIFIER, "____", 0, 0), eof(0, 4)]]
  [23, "____", [t(TOKEN.IDENTIFIER, "____", 0, 0), eof(0, 4)]]
  [24, "~!@#$%^&*-+={}[]|:;\"'<>?./", [
    t(TOKEN.ERROR.UNKNOWN_TOKEN, "~!@#$%^&*-+={}[]|:;\"'<>?./", 0, 0)
    eof(0, 26)
  ]]
  [25, "hoge fuga", [
    t(TOKEN.IDENTIFIER, "hoge", 0, 0)
    t(TOKEN.IDENTIFIER, "fuga", 0, 5)
    eof(0, 9)
  ]]
  [26, "hoge\nfuga", [
    t(TOKEN.IDENTIFIER, "hoge", 0, 0)
    t(TOKEN.LINE_BREAK, "\n", 0, 4)
    t(TOKEN.IDENTIFIER, "fuga", 1, 0)
    eof(1, 4)
  ]]
  [27, "a := b", [
    t(TOKEN.IDENTIFIER, "a", 0, 0)
    t(TOKEN.DEF_OP, ":=", 0, 2)
    t(TOKEN.IDENTIFIER, "b", 0, 5)
    eof(0, 6)
  ]]
]

describe "tokenizer", ->
  it "should have tokenize function", ->
    expect(typeof tokenizer.tokenize).to.be.equal "function"

  examples.forEach ([key, code, tokens]) ->
    it "should compile church encoding[#{key}]", ->
      lexer = tokenizer.tokenize code
      for expected in tokens
        c lexer.next(), expected

