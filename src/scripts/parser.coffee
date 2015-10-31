"use strict"

# EBNF
# + ... 1 回以上の繰り返し
# <expr>               ::= <identifier>
#                        | <lambda_abstraction>
#                        | <application>
#                        | <definition>
#                        | "(" <expr> ")"
# <identifier>         ::= /([_a-zA-Z0-9]+|[~!@#$%^&*\-+/?|]+)/
# <lambda_abstraction> ::= "\\" <identifier>+ "." <expr>
# <application>        ::= (<identifier> | "(" <expr> ")")+
# <definition>         ::= <identifier> ":=" <expr>
#

TOKEN = require "TOKEN"
AST = require "AST"

acceptor = (visitor) ->
  visitor.visit[@tag]? @

identifierNode = (idToken) ->
  tag: AST.IDENTIFIER
  token: idToken
  accept: acceptor

lambdaAbstractionNode = (identifiers, expr) ->
  tag: AST.LAMBDA_ABSTRACTION
  args: identifiers
  body: expr
  accept: acceptor

applicationNode = (args) ->
  tag: AST.APPLICATION
  args: args
  accept: acceptor

definitionNode = (idToken, expr) ->
  tag: AST.DEFINITION
  token: idToken
  body: expr
  accept: acceptor

parseIdentifier = (lexer) ->
  rewind = lexer.memento()
  token = lexer.next()
  return identifierNode token if token.tag is TOKEN.IDENTIFIER
  rewind()

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

  expr = parseExpr lexer
  return lambdaAbstractionNode identifiers, expr if expr?
  rewind()

parseApplication = (lexer) ->
  rewind = lexer.memento()
  rewindInner = lexer.memento()

  args = []
  while true
    rewindInner = lexer.memento()
    idNode = parseIdentifier lexer
    if idNode?
      args.push idNode
      continue

    token = lexer.next()
    break unless token.tag is TOKEN.BRACKETS_OPEN
    expr = parseExpr lexer
    break unless expr?
    token = lexer.next()
    break unless token.tag is TOKEN.BRACKETS_CLOSE
    args.push expr

  rewindInner()
  return applicationNode args if args.length > 1
  rewind()

parseDefinition = (lexer) ->
  rewind = lexer.memento()

  idToken = lexer.next()
  return rewind() unless idToken.tag is TOKEN.IDENTIFIER
  token = lexer.next()
  return rewind() unless token.tag is TOKEN.DEF_OP
  expr = parseExpr lexer

  return definitionNode idToken, expr if expr?
  rewind()

parseExprWithBrackets = (lexer) ->
  rewind = lexer.memento()
  token = lexer.next()
  return rewind() unless token.tag is TOKEN.BRACKETS_OPEN
  expr = parseExpr lexer
  return rewind() unless expr?
  token = lexer.next()
  return expr if token.tag is TOKEN.BRACKETS_CLOSE

  rewind()

parseExpr = (lexer) ->
  return parseExprWithBrackets(lexer) or
    parseDefinition(lexer) or
    parseApplication(lexer) or
    parseLambdaAbstraction(lexer) or
    parseIdentifier(lexer)

parse = (lexer) ->
  exprs = []
  while (expr = parseExpr lexer)?
    exprs.push expr
  return exprs

module.exports = {parse}

