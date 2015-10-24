"use strict"

module.exports = (sentence) ->
  return new Promise (resolve, reject) ->
    tokenChar =
      "\\": "LAMBDA"
      ".": "LAMBDA_BODY"
      "(": "BRACKETS_OPEN"
      ")": "BRACKETS_CLOSE"
      ";": "DEF_CLOSE"
  
    tokenRegex =
      DEF: /^:=/
      ID: /^([a-zA-Z0-9]+|[~!@#$%^&*\-_+/?|]+)/
  
    tokens = []
    f = (target) ->
      target = target.trim()
      if tokenChar[target[0]]
        tokens.push {value: target[0], name: tokenChar[target[0]]}
        return target.slice 1
  
      for k, v of tokenRegex
        matched = target.match v
        continue unless matched?
        tokens.push {value: matched[0], name: k}
        return target.slice matched[0].length
        
      throw "syntax error"
  
    target = sentence
    try
      while(target.length > 0)
        target = f target
      resolve tokens
    catch e
      reject e
