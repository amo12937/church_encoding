"use strict"

module.exports = do ->
  prefixedKV = (prefix, kv) ->
    res = {}
    for k, v of kv
      if Object.prototype.toString.call(v)[8...-1] is "Object"
        res[k] = prefixedKV "#{prefix}_#{k}", v
      else
        res[k] = "#{prefix}_#{v}"
    return res
  return prefixedKV
