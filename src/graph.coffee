EventEmitter = require('events').EventEmitter

###
# Class Graph - An representation of a graph of links and modules.
###
class Graph extends EventEmitter

  # Constructor
  constructor: () ->
    @modules = {}
    @links = {}

  # Runs any modules that have the 'start' config value
  start: () ->
    for key, mod of @modules
      do mod.start if mod.config.start

  # Exports a JSON representation of the Graph
  export: () ->
    obj = 
      modules: []
      links: []

    for id, module of @modules
      obj.modules.push module.config

    for id, link of @links
      obj.links.push 
        id: id
        source: link.source
        dest: link.dest

    obj

module.exports = Graph      