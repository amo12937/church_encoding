"use strict"

# EBNF
# S                    ::= (<application> "\n")+
# <application>        ::= <expr>+
# <expr>               ::= "(" <application> ")"
#                       |  <lambda_abstraction>
#                       |  <definition>
#                       |  <constant>
# <lambda_abstraction> ::= "\" <identifier>+ "." <application>
# <definition>         ::= <identifier> ":=" <application>
# <constant>           ::= <identifier>
#                       |  <natural_number>
#                       |  <string>
# <identifier>         ::= /^\w(?:\w|\d)+$/
# <natural_number>     ::= /^(?:0|[1-9]\d*)$/
# <string>             ::= /^(?:"((?:[^"\\]|\\.)*)"|'((?:[^'\\]|\\.)*)')/


TOKEN = require "TOKEN"
AST = require "AST"

exports.parse = (lexer, errors) -> parseMultiline lexer, errors

makeError = (name, token) -> {name, token}

parseMultiline = (lexer, errors) ->
  rewind = lexer.memento()
  rewindInner = lexer.memento()
  apps = []
  loop
    if app = parseApplication lexer, errors
      apps.push app

    rewindInner = lexer.memento
    token = lexer.next()
    continue if token.tag is TOKEN.LINE_BREAK
    rewindInner()
    break
  return listNode apps

parseApplication = (lexer, errors) ->
  rewind = lexer.memento()
  rewindInner = lexer.memento()

  exprs = []
  loop
    rewindInner = lexer.memento()
    break unless expr = parseExpr lexer, errors
    exprs.push expr

  rewindInner()
  return rewind() if exprs.length is 0
  [app, others...] = exprs
  app = applicationNode app, expr for expr in others
  return app

parseExpr = (lexer, errors) ->
  return parseApplicationWithBrackets(lexer, errors) or
    parseLambdaAbstraction(lexer, errors) or
    parseDefinition(lexer, errors) or
    parseConstant(lexer, errors)

parseApplicationWithBrackets = (lexer, errors) ->
  rewind = lexer.memento()
  oToken = lexer.next()
  return rewind() unless oToken.tag is TOKEN.BRACKETS_OPEN
  app = parseApplication lexer, errors
  unless app?
    errors.push makeError AST.ERROR.EXPECT.BRACKETS.TO_HAVE_BODY, oToken
    return rewind()
  cToken = lexer.next()
  return app if cToken.tag is TOKEN.BRACKETS_CLOSE
  errors.push makeError AST.ERROR.EXPECT.BRACKETS.TO_HAVE_CLOSER, oToken
  rewind()

parseLambdaAbstraction = (lexer, errors) ->
  rewind = lexer.memento()
  token = lexer.next()
  return rewind() unless token.tag is TOKEN.LAMBDA

  argTokens = []
  token = lexer.next()
  while token.tag is TOKEN.IDENTIFIER
    argTokens.push token
    token = lexer.next()
  
  if argTokens.length is 0
    errors.push makeError AST.ERROR.EXPECT.LAMBDA.TO_HAVE_AN_ARGUMENT, token
    return rewind()
  if token.tag isnt TOKEN.LAMBDA_BODY
    errors.push makeError AST.ERROR.EXPECT.LAMBDA.TO_HAVE_BODY, token
    return rewind()

  body = parseApplication lexer, errors
  unless body?
    errors.push makeError AST.ERROR.EXPECT.LAMBDA.TO_HAVE_BODY, lexer.next()
    return rewind()
  lmda = body
  for argToken in argTokens by -1
    lmda = lambdaAbstractionNode argToken.value, lmda
  return lmda

parseDefinition = (lexer, errors) ->
  rewind = lexer.memento()

  idToken = lexer.next()
  return rewind() unless idToken.tag is TOKEN.IDENTIFIER
  token = lexer.next()
  return rewind() unless token.tag is TOKEN.DEF_OP
  body = parseApplication lexer, errors

  return definitionNode idToken.value, body if body?

  errors.push makeError AST.ERROR.EXPECT.DEFINITION.TO_HAVE_BODY, token
  rewind()

parseConstant = (lexer, errors) ->
  rewind = lexer.memento()
  token = lexer.next()
  switch token.tag
    when TOKEN.IDENTIFIER     then return identifierNode token.value
    when TOKEN.NUMBER.NATURAL then return naturalNumberNode token.value
    when TOKEN.STRING         then return stringNode token.value, token.text
    else rewind()

# nodes
acceptor = (visitor) ->
  visitor.visit @

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

exports.stringNode = stringNode = (value, text) ->
  tag: AST.STRING
  value: value
  text: text
  accept: acceptor

