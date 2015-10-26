"use strict"

module.exports = do ->
  TOKEN = require "TOKEN"
  mementoContainer = require "memento_container"

  addToken = (context, value, type) ->
    context.tokens.push
      value: value
      type: type
      line: context.line
      position: context.position
    context.position += value.length
    context.target = context.target.slice value.length
    return context

  addError = (context) ->
    matched = context.target.match /^\S+/
    return unless matched?
    addToken context, matched[0], TOKEN.ERROR.UNKNOWN_TOKEN

  trim = (context) ->
    matched = context.target.match /^ +/
    return unless matched?
    context.position += matched[0].length
    context.target = context.target.slice matched[0].length
    return context

  commentToken =
    "#": (context) -> addToken context, context.target, TOKEN.COMMENT

  stringToken = do ->
    scanStringToken = (reg) -> (context) ->
      matched = context.target.match reg
      if matched?
        addToken context, matched[0], TOKEN.STRING
      else
        addToken context, context.target, TOKEN.ERROR.STRING
    return {
      "\"": scanStringToken /"([^\\"]|\\\\|\\")*"/
      "'": scanStringToken /'([^\\']|\\\\|\\')*'/
    }

  tokenChar =
    "\\": TOKEN.LAMBDA
    ".": TOKEN.LAMBDA_BODY
    "(": TOKEN.BRACKETS_OPEN
    ")": TOKEN.BRACKETS_CLOSE

  scanRegexToken = do ->
    tokenRegex = {}
    tokenRegex[TOKEN.DEF_OP] = /^:=/
    tokenRegex[TOKEN.IDENTIFIER] = /^([a-zA-Z0-9]+|[~!@#$%^&*\-_+/?|]+)/

    return (context) ->
      for type, reg of tokenRegex
        matched = context.target.match reg
        continue unless matched?
        addToken context, matched[0], type
        return true
      return false
  
  scanIndentToken = (context) ->
    matched = context.target.match /^ +/
    return unless matched?
    addToken context, matched[0], TOKEN.INDENT

  return (sentence) ->
    context =
      tokens: []

    for target, line in sentence.split "\n"
      context.target = target
      context.line = line
      context.position = 0

      # インデント
      scanIndentToken context

      while context.target.length > 0
        # ホワイトスペースの除去
        trim context

        c = context.target[0]

        # コメント判定
        continue if commentToken[c]? context

        # 文字列判定
        continue if stringToken[c]? context

        # 1文字トークン判定
        if tokenChar[c]?
          addToken context, c, tokenChar[c]
          continue

        # その他のトークン
        continue if scanRegexToken context

        # error
        addError context
    context.tokens.push
      value: ""
      name: TOKEN.EOF
      line: context.line
      position: context.position
    return mementoContainer.create context.tokens

