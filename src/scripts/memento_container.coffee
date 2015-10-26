"use strict"

create = (list) ->
  curr = 0
  max = list.length - 1

  next = ->
    item = list[curr]
    curr = Math.min curr + 1, max
    return item

  memento = -> do (mem = curr) -> ->
    curr = mem
    return

  return {next, memento}

module.exports = {create}

