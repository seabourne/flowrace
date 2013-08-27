EventEmitter = require('events').EventEmitter

###
# Class Module - The model class operates on data in some way
###
class Module extends EventEmitter

  # The constructor.
  # 
  # config: an optional configuration hash
  #
  constructor: (@config = {}) ->

  # Attaches the link to the module
  attach: (link) ->
    @emit 'attach', link
    link.on 'data', @process

  # Detaches the link from the module
  detach: (link) ->
    @emit 'detach', link
    link.off 'data', @process

  # Processes data
  process: (data) =>
    @emit 'data', data
    @emit 'complete'

  # Starts the processing. This should be implemented by the final classes.
  start: () ->
    #do something

module.exports = Module