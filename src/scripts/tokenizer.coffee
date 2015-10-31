"use strict"

TOKEN = require "TOKEN"
mementoContainer = require "memento_container"

module.exports = tokenize = (code) ->
  code = cleanCode code
  tokens = []
  line = 0
  column = 0

  addToken = (tag, value) ->
    token = {tag, value, line, column}
    tokens.push token
    token

  context =
    code:     code
    chunk:    code
    addToken: addToken

  i = 0
  while context.chunk = code[i..]
    consumed = commentToken(context)    or
               whitespaceToken(context) or
               lineToken(context)       or
               literalToken(context)    or
               identifierToken(context) or
               errorToken(context)
    i += consumed
    
    [dl, dc] = locationDiff context.chunk, consumed
    line   += dl
    column += dc

  addToken TOKEN.EOF, ""
  return mementoContainer.create tokens

cleanCode = (code) ->
  code = code.split("\r\n").join("\n").split("\r").join("\n")

# comment
COMMENT_LONG    = /^#-(?:[^-]|-(?!#))*-#/
COMMENT_ONELINE = /^#[^\n]*\n/
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
  c.addToken TOKEN.LINE_BREAK, "\n"
  return match[0].length

# literal
LITERAL_CHAR =
  "\\": TOKEN.LAMBDA
  ".": TOKEN.LAMBDA_BODY
  "(": TOKEN.BRACKETS_OPEN
  ")": TOKEN.BRACKETS_CLOSE
LITERAL_CHAR2 =
  ":=": TOKEN.DEF_OP

literalToken = (c) ->
  if (t = LITERAL_CHAR[v = c.chunk[0]])?
    c.addToken t, v
    return 1

  if (t = LITERAL_CHAR2[v = c.chunk[0..1]])?
    c.addToken t, v
    return 2

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

locationDiff = (chunk, offset) ->
  return [0, 0] if offset is 0
  str = chunk[0...offset]
  ls = str.split "\n"
  return [ls.length - 1, ls[ls.length - 1].length]
