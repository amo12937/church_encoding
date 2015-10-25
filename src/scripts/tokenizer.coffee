"use strict"

module.exports = do ->
  genPrefixedKV = (prefix, kv) ->
    res = {}
    for k, v of kv
      if Object.prototype.toString.call(v)[8...-1] is "Object"
        res[k] = genPrefixedKV "#{prefix}_#{k}", v
      else
        res[k] = "#{prefix}_#{v}"
    return res
        
  TOKEN = genPrefixedKV "TOKEN", {
    "COMMENT"
    "STRING"
    "LAMBDA"
    "LAMBDA_BODY"
    "BRACKETS_OPEN"
    "BRACKETS_CLOSE"
    "DEF_CLOSE"
    "DEF"
    "ID"
    ERROR: {
      "STRING"
      "UNKNOWN_TOKEN"
    }
  }

  addToken = (context, value, name) ->
    console.log "addToken"
    context.tokens.push
      value: value
      name: name
      line: context.line
      position: context.position
    context.position += value.length
    context.target = context.target.slice value.length
    return context

  addError = (context) ->
    console.log "addError"
    matched = context.target.match /^\S+/
    return unless matched?
    addToken context, matched[0], TOKEN.ERROR.UNKNOWN_TOKEN

  trim = (context) ->
    console.log "trim"
    matched = context.target.match /^\s+/
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
    ";": TOKEN.DEF_CLOSE

  scanRegexToken = do ->
    tokenRegex = {}
    tokenRegex[TOKEN.DEF] = /^:=/
    tokenRegex[TOKEN.ID] = /^([a-zA-Z0-9]+|[~!@#$%^&*\-_+/?|]+)/

    return (context) ->
      console.log "scanRegex"
      for name, reg of tokenRegex
        matched = context.target.match reg
        continue unless matched?
        addToken context, matched[0], name
        return true
      return false

  return (sentence) ->
    context =
      tokens: []

    for target, line in sentence.split "\n"
      context.target = target
      context.line = line
      context.position = 0

      while context.target.length > 0
        # ホワイトスペースの除去
        trim context
        console.log context.target, context.target.length

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
    return context.tokens

