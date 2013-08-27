EventEmitter = require('events').EventEmitter
GraphBuilder = require "./graphbuilder"

class Flowrace extends EventEmitter

  constructor: () ->
    @_counts = 
      completeEvents: 0
      starts: 0
      startsCompleted: 0
      dataEvents: 0
    @_modules = {}
    @_graph = null

  run: (config) ->
    @_graph = @_buildGraph config
    @_bindEvents @_graph
    @emit 'start'
    @_graph.start()

  _buildGraph: (config) ->
    @_graph = GraphBuilder::parse config, @_modules
    for id, module of @_graph.modules
      @_counts.starts++ if module.config.start
    return @_graph

  _bindEvents: (graph) ->
    for id, link of graph.links
      link.connect()
      do (link) =>
        link.on 'dataReceived', (data, source, dest) =>
          @_counts.dataEvents++
          @emit 'data', data, source, dest

    for id, module of graph.modules
      do (module) =>
        module.on 'complete', () => 
          @_counts.completeEvents++ if not module.config.start
          @_counts.startsCompleted++ if module.config.start
          if @_counts.completeEvents >= @_counts.dataEvents and @_counts.startsCompleted is @_counts.starts
            console.log 'ending'
            @emit 'end' 

  use: (name, module) ->
    @_modules[name] = module

module.exports = Flowrace
