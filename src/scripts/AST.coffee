"use strict"

prefixedKV = require "prefixed_kv"

module.exports = prefixedKV "AST", {
  "LIST"
  "APPLICATION"
  "LAMBDA_ABSTRACTION"
  "DEFINITION"
  "IDENTIFIER"
  NUMBER: {
    "NATURAL"
  }
  "STRING"
  ERROR:
    EXPECT:
      BRACKETS: {
        "TO_HAVE_CLOSER"
        "TO_HAVE_BODY"
      }
      LAMBDA: {
        "TO_HAVE_AN_ARGUMENT"
        "TO_HAVE_BODY"
      }
      DEFINITION: {
        "TO_HAVE_BODY"
      }
}
