EventEmitter = require('events').EventEmitter
Link = require "./link"
Graph = require "./graph"

###
# Class GraphBuilder - parses a Graph JSON object and builds the Graph Object.
###
class GraphBuilder extends EventEmitter

  # Parses the config JSON object or string and returns a Graph object
  #
  # config: a valid graph JSON object or parsable string
  # modules: an object of modules to use to instantiate the Graph, in the form 
  #   of {name: type}
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
      newLink.connect()

    graph

module.exports = GraphBuilder    