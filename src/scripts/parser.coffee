"use strict"

# EBNF
# S                    ::= <application>
# <application>        ::= <expr>+
# <expr>               ::= "(" <application> ")"
#                       |  <lambda_abstraction>
#                       |  <definition>
#                       |  <identifier>
# <lambda_abstraction> ::= "\" <identifier>+ "." <application>
# <definition>         ::= <identifier> ":=" <application>
# <identifier>         ::= /^\w+$/


TOKEN = require "TOKEN"
AST = require "AST"

exports.parse = (lexer) ->
  apps = []
  while app = parseApplication lexer
    apps.push app
  return apps

parseApplication = (lexer) ->
  rewind = lexer.memento()
  rewindInner = lexer.memento()

  exprs = []
  loop
    rewindInner = lexer.memento()
    break unless expr = parseExpr lexer
    exprs.push expr

  rewindInner()
  return applicationNode exprs if exprs.length > 0
  rewind()

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

  identifiers = []
  token = lexer.next()
  while token.tag is TOKEN.IDENTIFIER
    identifiers.push token
    token = lexer.next()
  return rewind() if identifiers.length is 0 or token.tag isnt TOKEN.LAMBDA_BODY

  app = parseApplication lexer
  return lambdaAbstractionNode identifiers, app if app?
  rewind()

parseDefinition = (lexer) ->
  rewind = lexer.memento()

  idToken = lexer.next()
  return rewind() unless idToken.tag is TOKEN.IDENTIFIER
  token = lexer.next()
  return rewind() unless token.tag is TOKEN.DEF_OP
  app = parseApplication lexer

  return definitionNode idToken, app if app?
  rewind()

parseIdentifier = (lexer) ->
  rewind = lexer.memento()
  token = lexer.next()
  return identifierNode token if token.tag is TOKEN.IDENTIFIER
  rewind()

# nodes
acceptor = (visitor) ->
  visitor.visit[@tag]? @

applicationNode = (exprs) ->
  tag: AST.APPLICATION
  exprs: exprs
  accept: acceptor

lambdaAbstractionNode = (args, app) ->
  tag: AST.LAMBDA_ABSTRACTION
  args: args
  body: app
  accept: acceptor

definitionNode = (idToken, app) ->
  tag: AST.DEFINITION
  token: idToken
  body: app
  accept: acceptor

identifierNode = (idToken) ->
  tag: AST.IDENTIFIER
  token: idToken
  accept: acceptor

