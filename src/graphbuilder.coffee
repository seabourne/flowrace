EventEmitter = require('events').EventEmitter
Link = require "./link"
Graph = require "./graph"

class GraphBuilder extends EventEmitter

  parse: (config, modules) ->
    graph = new Graph

    if typeof config is 'string'
      try
        config = JSON.parse config  
      catch e
        throw new Error 'Config must be a valid JSON object'

    for mod in config.modules
      type = mod.type
      throw new Error 'Module must have a type' unless type
      if not modules[type]
        try
          instance = require type
        catch e
          throw new Error "Module type #{type} not found"
      else 
        instance = new modules[type](mod)
      graph.modules[mod.id] = instance

    for link in config.links
      source = graph.modules[link.source]
      dest = graph.modules[link.dest]
      newLink = new Link source, dest
      graph.links[link.id] = newLink

    graph

module.exports = GraphBuilder    