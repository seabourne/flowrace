EventEmitter = require('events').EventEmitter

###
# Class Module - The model class operates on data in some way
###
class Module extends EventEmitter

  # The constructor.
  # 
  # config: an optional configuration hash
  #
  constructor: (@data = {}) ->
    @isCompleted = false

  # Attaches the link to the module
  attach: (link) ->
    @emit 'attach', link
    #link.on 'data', @process if link
    link.on 'data', (data) =>
      try 
        @process data
      catch e
        @complete "Error processing module: "+e


  # Detaches the link from the module
  detach: (link) ->
    @emit 'detach', link
    link.removeListener 'data', @process if link

  preprocess: () =>
    do @complete

  # Processes data
  process: (data) =>
    @done data
    do @complete

  postprocess: () =>
    do @complete

  done: (data) ->
    @emit 'data', data

  complete: (error, data) ->
    process.nextTick =>
      @isCompleted = true
      @emit 'complete', error, data

  info: (message, data) ->
    @emit 'info', message, data

  # Starts the processing. This should be implemented by the final classes.
  start: (cb) ->
    do cb if cb
    #do something

module.exports = Module