"use strict"

chai = require "chai"
expect = chai.expect
sinon = require "sinon"
sinonChai = require "sinon-chai"
chai.use sinonChai

AST = "AST"
tokenizer = require "tokenizer"
parser = require "parser"
visitorProvider = require "visitor/cs_visitor"
visitor = visitorProvider.create()
examples = require "examples"

describe "parser", ->
  it "should have parse function", ->
    expect(typeof parser.parse).to.be.equal "function"

  examples.forEach ([key, code, expected]) ->
    it "should compile church encoding[#{key}]", ->
      lexer = tokenizer.tokenize code
      results = parser.parse lexer
      expect(results.length).to.be.equal expected.length
      for result, idx in results
        expect(result).to.have.property "accept"
        expect(result.accept visitor).to.be.equal expected[idx]

