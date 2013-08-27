EventEmitter = require('events').EventEmitter
GraphBuilder = require "./graphbuilder"

###
# Class Flowrace - Provides the external interface for processing
# flow configurations.
###
class Flowrace extends EventEmitter

  # Initializes internal objects.
  # 
  # _moduleTypes: optionally pass in a hash of module types in the form of {name: type}
  #
  constructor: (@_moduleTypes = {}) ->
    @_counts = 
      completeEvents: 0
      starts: 0
      startsCompleted: 0
      dataEvents: 0
    @_graph = null

  # Returns the internally prepared graph
  graph: () ->
    return @_graph

  # Loads and runs a flow based on a flow configuration.
  # 
  # config: can be either a valid JSON object or parsable string
  #
  run: (config) ->
    @_graph = @_buildGraph config
    @_bindEvents @_graph
    @emit 'start'
    @_graph.start()

  # Builds the graph based on the config. Sets up the internal counts.
  # 
  # config: can be either a valid JSON object or a parsable string
  _buildGraph: (config) ->
    @_graph = GraphBuilder::parse config, @_moduleTypes
    for id, module of @_graph.modules
      @_counts.starts++ if module.config.start
    return @_graph

  # Bind to the data and complete events on links and modules.
  #
  # graph: a valid graph object
  # 
  _bindEvents: (graph) ->
    for id, link of graph.links
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
            @emit 'end' 

  # Register a module for use by the flow. This needs to be done before you load the flow config.
  #
  # name: a unique name for the module, referenced in the 'type' field of your flow config.
  # module: a valid class extending the Flowrace.Module class
  #  
  use: (name, module) ->
    @_moduleTypes[name] = module

module.exports = Flowrace
