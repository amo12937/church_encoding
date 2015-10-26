"use strict"

prefixedKV = require "prefixed_kv"

module.exports = prefixedKV "TOKEN", {
  "COMMENT"
  "STRING"
  "LAMBDA"
  "LAMBDA_BODY"
  "BRACKETS_OPEN"
  "BRACKETS_CLOSE"
  "DEF_OP"
  "IDENTIFIER"
  "INDENT"
  "EOF"
  ERROR: {
    "STRING"
    "UNKNOWN_TOKEN"
  }
}
