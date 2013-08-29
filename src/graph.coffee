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

  # Runs any modules that have the 'start' config value
  start: () ->
    debug "Starting Graph"
    do @connect unless @connected
    for key, mod of @modules
      if mod.data.start
        debug 'Starting module', mod
        do mod.process

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