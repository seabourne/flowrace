EventEmitter = require('events').EventEmitter

class Module extends EventEmitter

  constructor: (@config) ->

  attach: (link) ->
    @emit 'attach', link
    link.on 'data', @process

  process: (data) =>
    @emit 'data', data
    @emit 'complete'

  start: () ->
    #do something

module.exports = Module