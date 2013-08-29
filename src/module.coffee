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
    @completed = false

  # Attaches the link to the module
  attach: (link) ->
    @emit 'attach', link
    link.on 'data', @process
    ###
    link.on 'data', (data) =>
      try 
        @process data
      catch e
        @emit 'complete', e
    ###  

  # Detaches the link from the module
  detach: (link) ->
    @emit 'detach', link
    link.off 'data', @process

  # Processes data
  process: (data) =>
    @done data
    do @complete

  done: (data) ->
    @emit 'data', data

  complete: (error) ->
    process.nextTick =>
      @completed = true
      @emit 'complete', error 

  # Starts the processing. This should be implemented by the final classes.
  start: (cb) ->
    do cb if cb
    #do something

module.exports = Module