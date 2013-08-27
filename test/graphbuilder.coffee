GraphBuilder = require '../src/graphbuilder'
Link = require "../src/link"

should = require 'should'
_ = require 'underscore'

config = require './fixtures/simpleflow.json'

modules = 
  module1: require "./fixtures/module1"
  module2: require "./fixtures/module2"

describe "GraphBuilder", ->

  describe "Parse", ->
    it "should parse the config", (done) ->
      res = GraphBuilder::parse config, modules
      _.size(res.modules).should.eql 2
      _.size(res.links).should.eql 1
      done()

    it "should parse the config if its a valid string", (done) ->
      config = JSON.stringify config
      res = GraphBuilder::parse config, modules
      _.size(res.modules).should.eql 2
      _.size(res.links).should.eql 1
      done()  

    it "should throw an error if the modules don't exist", (done) ->
      (() ->
        GraphBuilder::parse(config, {})
      ).should.throw(/module/)
      done()

    it "should throw an error if the config is invalid", (done) ->
      (() ->
        GraphBuilder::parse('invalidConfig', {})
      ).should.throw(/JSON/)
      done()  