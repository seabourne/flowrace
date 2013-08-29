EventEmitter = require('events').EventEmitter
GraphBuilder = require "./graphbuilder"
debug = require('debug')('Flowrace')

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
    @_graph = null
    @running = false

  # Returns the internally prepared graph
  graph: () ->
    return @_graph

  # Loads and runs a flow based on a flow configuration.
  # 
  # config: can be either a valid JSON object or parsable string
  #
  run: (config) ->
    debug 'Running config', config
    @_graph = @_buildGraph config
    @_bindEvents @_graph
    @running = true
    @emit 'start'
    @_graph.start()

  # Builds the graph based on the config. Sets up the internal counts.
  # 
  # config: can be either a valid JSON object or a parsable string
  _buildGraph: (config) ->
    debug 'Building graph', config
    @_graph = GraphBuilder::parse config, @_moduleTypes
    return @_graph

  # Bind to the data and complete events on links and modules.
  #
  # graph: a valid graph object
  # 
  _bindEvents: (graph) ->
    debug 'Binding events', graph

    for id, module of graph.modules
      do (module) =>
        module.on 'data', (data) =>
          debug 'Emitting Flow::data event'
          @emit 'data', data, module

        module.on 'complete', (error) => 
          if error
            debug 'Emitting error', error.toString()
            @emit 'error', error, module
            @running = false
          for key, link of @_graph.links
            return unless link.complete()
          debug 'Emitting Flow::end event'
          @emit 'end' if @running 


  # Register a module for use by the flow. This needs to be done before you load the flow config.
  #
  # className: a unique name for the module, referenced in the 'type' field of your flow config.
  # module: a valid class extending the Flowrace.Module class
  #  
  use: (className, module) ->
    debug 'Adding module', className
    @_moduleTypes[className] = module

module.exports = Flowrace
