EventEmitter = require('events').EventEmitter

###
# Class Link - represents a connection between two modules
###
class Link extends EventEmitter

  # Constructs the link
  # 
  # source: the source module
  # dest: the destination module
  #
  constructor: (source, dest) ->
    @source = source
    @dest = dest
    @dest.attach @

  # Creates the connection between the source and dest
  connect: () ->
    @emit 'connect', source, dest
    @source.on 'data', @onData

  # Removes the connection between the source and dest
  disconnect: () ->
    @emit 'disconnect', source, dest
    @source.off 'data', @onData
    @dest.detach @

  # Sends the data packet through to the dest.
  onData: (data) =>
    @emit 'dataReceived', @source
    process.nextTick => @emit 'data', data, @source, @dest

module.exports = Link