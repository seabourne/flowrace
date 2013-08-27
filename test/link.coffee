Link = require "../src/link"

should = require 'should'
_ = require 'underscore'

config = require './fixtures/simpleflow.json'

modules = 
  module1: require "./fixtures/module1"
  module2: require "./fixtures/module2"

describe "Link", ->

  describe "Constructor", ->

    it "should call attach of destination", (done) ->
      source = new modules.module1
      dest = new modules.module2
      dest.on 'attach', (l) ->
        should.exist l
        l.should.be.an.instanceOf(Link)
        done()
      link = new Link source, dest

  describe "Connect", ->
    it "should link the source and destination", (done) ->
      source = new modules.module1
      dest = new modules.module2
      dest.on 'data', (data) ->
        data.should.eql 'somedata'
        done()
      link = new Link source, dest
      link.connect()
      do source.start