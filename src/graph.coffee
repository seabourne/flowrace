EventEmitter = require('events').EventEmitter
debug = require("debug")("Flowrace")

###
# Class Graph - An representation of a graph of links and modules.
###
class Graph extends EventEmitter

  # Constructor
  constructor: () ->
    @modules = {}
    @links = {}
    @connected = false

  preprocess: (cb) =>
    debug 'preprocessing'
    modules = []
    for id, mod of @modules
      modules.push mod
      mod.once 'complete', () =>
        if modules.length is 0
          return cb() if cb
        do modules.pop().preprocess

    modules.pop().preprocess()

  process: () =>
    debug 'processing'
    @connect()
    for key, mod of @modules
      mod.isCompleted = false
      if mod.data.start
        debug 'processing module', mod
        do mod.process

  postprocess: (cb) =>
    @disconnect()
    debug 'postprocessing'
    modules = []
    for id, mod of @modules
      mod.isCompleted = false
      modules.push mod
      mod.once 'complete', () =>
        if modules.length is 0
          return cb() if cb
        do modules.pop().postprocess

    modules.pop().postprocess()
    
  connect: () ->
    return if @connected
    for id, link of @links
      do link.connect
    @connected = true

  disconnect: () ->
    return unless @connected
    for id, link of @links
      do link.disconnect
    @connected = false

  addModule: (id, module) ->
    @modules[id] = module

  removeModule: (id) ->
    delete @modules[id] if @modules[id]

  addLink: (id, link) ->
    @links[id] = link

  removeLink: (id) ->
    delete @links[id] if @links[id]
    

module.exports = Graph      