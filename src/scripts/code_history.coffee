"use strict"

exports.create = (history = []) ->
  tmp = []
  i = history.length

  prev: (code) ->
    return code if i <= 0
    tmp[i] = code
    i -= 1
    return tmp[i] or history[i] or ""

  next: (code) ->
    return code if i >= history.length
    tmp[i] = code
    i += 1
    return tmp[i] or history[i] or ""

  save: (code) ->
    history.push code
    i = history.length
    tmp = []
    return ""

