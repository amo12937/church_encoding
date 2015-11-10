"use strict"

# EBNF
# S                    ::= (<application> "\n")+
# <application>        ::= <expr>+
# <expr>               ::= "(" <application> ")"
#                       |  <lambda_abstraction>
#                       |  <definition>
#                       |  <identifier>
#                       |  <natural_number>
# <lambda_abstraction> ::= "\" <identifier>+ "." <application>
# <definition>         ::= <identifier> ":=" <application>
# <identifier>         ::= /^\w(?:\w|\d)+$/
# <natural_number>     ::= /^(?:0|[1-9]\d*)$/


TOKEN = require "TOKEN"
AST = require "AST"

exports.parse = (lexer) -> parseMultiline lexer

parseMultiline = (lexer) ->
  rewind = lexer.memento()
  rewindInner = lexer.memento()
  apps = []
  loop
    if app = parseApplication lexer
      apps.push app

    rewindInner = lexer.memento
    token = lexer.next()
    continue if token.tag is TOKEN.LINE_BREAK
    rewindInner()
    break
  return listNode apps

parseApplication = (lexer) ->
  rewind = lexer.memento()
  rewindInner = lexer.memento()

  exprs = []
  loop
    rewindInner = lexer.memento()
    break unless expr = parseExpr lexer
    exprs.push expr

  rewindInner()
  return rewind() if exprs.length is 0
  [app, others...] = exprs
  app = applicationNode app, expr for expr in others
  return app

parseExpr = (lexer) ->
  return parseApplicationWithBrackets(lexer) or
    parseLambdaAbstraction(lexer) or
    parseDefinition(lexer) or
    parseIdentifier(lexer)

parseApplicationWithBrackets = (lexer) ->
  rewind = lexer.memento()
  token = lexer.next()
  return rewind() unless token.tag is TOKEN.BRACKETS_OPEN
  app = parseApplication lexer
  return rewind() unless app?
  token = lexer.next()
  return rewind() unless token.tag is TOKEN.BRACKETS_CLOSE
  return app

parseLambdaAbstraction = (lexer) ->
  rewind = lexer.memento()
  token = lexer.next()
  return rewind() unless token.tag is TOKEN.LAMBDA

  argTokens = []
  token = lexer.next()
  while token.tag is TOKEN.IDENTIFIER
    argTokens.push token
    token = lexer.next()
  return rewind() if argTokens.length is 0 or token.tag isnt TOKEN.LAMBDA_BODY

  body = parseApplication lexer
  return rewind() unless body?
  lmda = body
  for argToken in argTokens by -1
    lmda = lambdaAbstractionNode argToken.value, lmda
  return lmda

parseDefinition = (lexer) ->
  rewind = lexer.memento()

  idToken = lexer.next()
  return rewind() unless idToken.tag is TOKEN.IDENTIFIER
  token = lexer.next()
  return rewind() unless token.tag is TOKEN.DEF_OP
  body = parseApplication lexer

  return definitionNode idToken.value, body if body?
  rewind()

parseIdentifier = (lexer) ->
  rewind = lexer.memento()
  token = lexer.next()
  switch token.tag
    when TOKEN.IDENTIFIER then return identifierNode token.value
    when TOKEN.NUMBER.NATURAL then return naturalNumberNode token.value
    else rewind()

# nodes
acceptor = (visitor) ->
  visitor.visit[@tag]? @

exports.listNode = listNode = (exprs) ->
  tag: AST.LIST
  exprs: exprs
  accept: acceptor

exports.applicationNode = applicationNode = (left, right) ->
  tag: AST.APPLICATION
  left: left
  right: right
  accept: acceptor

exports.lambdaAbstractionNode = lambdaAbstractionNode = (arg, body) ->
  tag: AST.LAMBDA_ABSTRACTION
  arg: arg
  body: body
  accept: acceptor

exports.definitionNode = definitionNode = (name, body) ->
  tag: AST.DEFINITION
  name: name
  body: body
  accept: acceptor

exports.identifierNode = identifierNode = (name) ->
  tag: AST.IDENTIFIER
  name: name
  accept: acceptor

exports.naturalNumberNode = naturalNumberNode = (value) ->
  tag: AST.NUMBER.NATURAL
  value: +value
  accept: acceptor

