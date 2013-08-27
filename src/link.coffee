EventEmitter = require('events').EventEmitter

class Link extends EventEmitter

  constructor: (source, dest) ->
    @source = source
    @dest = dest
    @dest.attach @

  connect: () ->
    @source.on 'data', @onData

  onData: (data) =>
    @emit 'dataReceived', @source
    process.nextTick => @emit 'data', data, @source, @dest

module.exports = Link