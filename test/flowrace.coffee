Flowrace = require '../src/flowrace'

should = require 'should'
_ = require 'underscore'

config = require './fixtures/complexflow.json'

describe "Flowrace", ->

  describe "Run", ->
    it "should run the config", (done) ->
      count = 0
      flowrace = new Flowrace
      flowrace.on 'data', (data) ->
        count++
        done() if count is 3
      flowrace.use 'module1', require "./fixtures/module1"
      flowrace.use 'module2', require "./fixtures/module2"
      flowrace.run config

    it "should fire the start event", (done) ->
      flowrace = new Flowrace
      flowrace.on 'start', () ->
        done()
      flowrace.use 'module1', require "./fixtures/module1"
      flowrace.use 'module2', require "./fixtures/module2"
      flowrace.run config

    it "should fire the end event", (done) ->
      flowrace = new Flowrace
      flowrace.on 'end', () ->
        done()
      flowrace.use 'module1', require "./fixtures/module1"
      flowrace.use 'module2', require "./fixtures/module2"
      flowrace.run config