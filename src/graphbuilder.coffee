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
  #   of {name: class}
  parse: (config, modules) ->
    graph = new Graph

    if typeof config is 'string'
      try
        config = JSON.parse config  
      catch e
        throw new Error 'Config must be a valid JSON object'

    for mod in config.modules
      className = mod.class
      throw new Error 'Module must have a class' unless className
      if not modules[className]
        try
          instance = require className
        catch e
          throw new Error "Module class #{className} not found"
      else 
        instance = new modules[className](mod)
      graph.modules[mod.id] = instance

    for link in config.links
      source = graph.modules[link.source]
      dest = graph.modules[link.dest]
      newLink = new Link source, dest
      graph.links[link.id] = newLink
    
    graph

  export: (graph) ->
    obj = 
      modules: []
      links: []

    for id, module of graph.modules
      obj.modules.push module

    for id, link of graph.links
      obj.links.push 
        id: id
        source: link.source.data.id
        dest: link.dest.data.id

    obj

module.exports = GraphBuilder    