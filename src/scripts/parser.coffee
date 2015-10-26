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
  visitor.visit[@type]? @

identifierNode = (idToken) ->
  type: AST.IDENTIFIER
  token: idToken
  accept: acceptor

lambdaAbstractionNode = (identifiers, expr) ->
  type: AST.LAMBDA_ABSTRACTION
  args: identifiers
  body: expr
  accept: acceptor

applicationNode = (args) ->
  type: AST.APPLICATION
  args: args
  accept: acceptor

definitionNode = (idToken, expr) ->
  type: AST.DEFINITION
  token: idToken
  body: expr
  accept: acceptor

parseIdentifier = (lexer) ->
  rewind = lexer.memento()
  token = lexer.next()
  return identifierNode token if token.type is TOKEN.IDENTIFIER
  rewind()

parseLambdaAbstraction = (lexer) ->
  rewind = lexer.memento()
  token = lexer.next()
  return rewind() unless token.type is TOKEN.LAMBDA

  identifiers = []
  token = lexer.next()
  while token.type is TOKEN.IDENTIFIER
    identifiers.push token
    token = lexer.next()
  return rewind() if identifiers.length is 0 or token.type isnt TOKEN.LAMBDA_BODY

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
    break unless token.type is TOKEN.BRACKETS_OPEN
    expr = parseExpr lexer
    break unless expr?
    token = lexer.next()
    break unless token.type is TOKEN.BRACKETS_CLOSE
    args.push expr

  rewindInner()
  return applicationNode args if args.length > 1
  rewind()

parseDefinition = (lexer) ->
  rewind = lexer.memento()

  idToken = lexer.next()
  return rewind() unless idToken.type is TOKEN.IDENTIFIER
  token = lexer.next()
  return rewind() unless token.type is TOKEN.DEF_OP
  expr = parseExpr lexer

  return definitionNode idToken, expr if expr?
  rewind()

parseExprWithBrackets = (lexer) ->
  rewind = lexer.memento()
  token = lexer.next()
  return rewind() unless token.type is TOKEN.BRACKETS_OPEN
  expr = parseExpr lexer
  return rewind() unless expr?
  token = lexer.next()
  return expr if token.type is TOKEN.BRACKETS_CLOSE

  rewind()

parseExpr = (lexer) ->
  return parseExprWithBrackets(lexer) or
    parseLambdaAbstraction(lexer) or
    parseDefinition(lexer) or
    parseApplication(lexer) or
    parseIdentifier(lexer)

parse = (lexer) ->
  exprs = []
  while (expr = parseExpr lexer)?
    exprs.push expr
  return exprs

module.exports = {parse}

