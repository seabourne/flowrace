EventEmitter = require('events').EventEmitter
debug = require('debug')('Flowrace')
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
    @dest.attach @ if @dest.attach
    @_count = 
      source: 0
      dest: 0
    @dest.on 'complete', () =>
      @_count.dest++

  complete: () ->
    debug 'count=',@_count
    return @_count.source <= @_count.dest and @_count.source isnt 0 and ((@source.start and @source.completed) or not @source.start)

  # Creates the connection between the source and dest
  connect: () ->
    @emit 'connect', @source, @dest
    @source.on 'data', @onData

  # Removes the connection between the source and dest
  disconnect: () ->
    @emit 'disconnect', @source, @dest
    @source.off 'data', @onData
    @dest.detach @ if @dest.detach

  # Sends the data packet through to the dest.
  onData: (data) =>
    @_count.source++
    @emit 'dataReceived', data, @source, @dest
    process.nextTick => @emit 'data', data, @source, @dest

module.exports = Link