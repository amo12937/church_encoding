"use strict"

TOKEN = require "TOKEN"
mementoContainer = require "memento_container"

exports.tokenize = (code) ->
  code = cleanCode code
  tokens = []
  line = 0
  column = 0
  brackets = []

  addToken = (tag, value, length = value.length) ->
    token = {tag, value, line, column}
    tokens.push token
    return length

  pushBracket = (b) -> brackets.push b
  popBracket = -> brackets.pop()
  latestBracket = -> brackets[brackets.length - 1]

  context =
    code:     code
    chunk:    code
    parenthesisStack: []
    addToken: addToken
    brackets:
      push: pushBracket
      pop: popBracket
      latest: latestBracket

  i = 0
  while context.chunk = code[i..]
    consumed = commentToken(context)    or
               whitespaceToken(context) or
               lineToken(context)       or
               literalToken(context)    or
               identifierToken(context) or
               errorToken(context)
    i += consumed
    
    [line, column] = updateLocation line, column, context.chunk, consumed

  addToken TOKEN.EOF, ""
  return mementoContainer.create tokens

cleanCode = (code) ->
  code = code.split("\r\n").join("\n").split("\r").join("\n")

# comment
COMMENT_LONG    = /^#-(?:[^-]|-(?!#))*-#/
COMMENT_ONELINE = /^#[^\n]*(?=\n|$)/
commentToken = (c) ->
  match = c.chunk.match(COMMENT_LONG) or
          c.chunk.match(COMMENT_ONELINE)
  return match?[0].length or 0

# whitespace
WHITESPACE = /^[^\n\S]+/
whitespaceToken = (c) ->
  match = c.chunk.match WHITESPACE
  return match?[0].length or 0

MULTI_DENT = /^\s*\n([^\n\S]*)/
lineToken = (c) ->
  return 0 unless match = c.chunk.match MULTI_DENT
  return match[0].length if c.brackets.latest()?
  return c.addToken TOKEN.LINE_BREAK, "\n", match[0].length

# literal
LITERAL_CHAR =
  "\\": TOKEN.LAMBDA
  ".": TOKEN.LAMBDA_BODY
LITERAL_OPENER =
  "(":
    token: TOKEN.BRACKETS_OPEN
    opposite: ")"
LITERAL_CLOSER =
  ")": TOKEN.BRACKETS_CLOSE
LITERAL_CHAR2 =
  ":=": TOKEN.DEF_OP

literalToken = (c) ->
  v = c.chunk[0]
  return c.addToken t, v if (t = LITERAL_CHAR[v])?

  if (t = LITERAL_OPENER[v])?
    c.brackets.push t.opposite
    return c.addToken t.token, v
  
  if (t = LITERAL_CLOSER[v])?
    return c.addToken TOKEN.ERROR.UNMATCHED_BRACKET, v unless c.brackets.latest() is v
    c.brackets.pop()
    return c.addToken t, v

  v = c.chunk[0..1]
  return c.addToken t, v if (t = LITERAL_CHAR2[v])?
  
  return 0

# identifier
IDENTIFIER = /^[_a-zA-Z0-9]+/
identifierToken = (c) ->
  return 0 unless match = c.chunk.match IDENTIFIER
  c.addToken TOKEN.IDENTIFIER, match[0]
  return match[0].length

# error
ERROR = /^\S+/
errorToken = (c) ->
  return 0 unless match = c.chunk.match ERROR
  c.addToken TOKEN.ERROR.UNKNOWN_TOKEN, match[0]
  return match[0].length

updateLocation = (l, c, chunk, offset) ->
  return [0, 0] if offset is 0
  str = chunk[0...offset]
  ls = str.split "\n"
  dl = ls.length - 1
  if dl is 0
    return [l, c + ls[dl].length]
  return [l + dl, ls[dl].length]
