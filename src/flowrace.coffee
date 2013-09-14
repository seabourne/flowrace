EventEmitter = require('events').EventEmitter
GraphBuilder = require "./graphbuilder"
debug = require('debug')('Flowrace')
_ = require 'underscore'
###
# Class Flowrace - Provides the external interface for processing
# flow configurations.
###
class Flowrace extends EventEmitter

  # Initializes internal objects.
  # 
  # _moduleTypes: optionally pass in a hash of module types in the form of {name: type}
  #
  constructor: (@config, @_moduleTypes = {}) ->
    @_graph = null
    @running = false

  # Returns the internally prepared graph
  graph: () ->
    return @_graph

  setConfig: (@config) ->
    @_graph = null

  setup: () ->
    @_buildGraph @config
    @_bindEvents @_graph

  # Loads and runs a flow based on a flow configuration.
  # 
  # config: can be either a valid JSON object or parsable string
  #
  run: () ->
    do @setup unless @_graph
    debug 'Running'
    @running = true
    @_state = 'preprocess'
    @emit 'start'
    @emit @_state
    @_graph.preprocess =>
      @_state = 'process'
      @emit @_state
      @_graph.process()

  # Builds the graph based on the config. Sets up the internal counts.
  # 
  # config: can be either a valid JSON object or a parsable string
  _buildGraph: () ->
    debug 'Building graph', @config
    @_graph = GraphBuilder::parse @config, @_moduleTypes
    return @_graph

  # Bind to the data and complete events on links and modules.
  #
  # graph: a valid graph object
  # 
  _bindEvents: (graph) ->
    debug 'Binding events', graph

    graph.on 'process', () =>
      @emit 'process'

    graph.on 'preprocess', () =>
      @emit 'preprocess'

    graph.on 'postprocess', () =>
      @emit 'postprocess'      

    for id, module of graph.modules
      do (module) =>
        module.on 'data', (data) =>
          debug 'Emitting Flow::data event'
          @emit 'data', data, module

        module.on 'info', (message, data) =>
          debug 'Emitting Flow::info event'
          @emit 'info', message, data, module

        module.on 'complete', (error, data) => 
          debug 'complete event received'
          if error
            debug 'Emitting error', error.toString()
            @emit 'error', error, data, module
          if _.size(graph.modules) > 1
            for key, link of @_graph.links
              return unless link.complete()
          if @_state is 'process'
            @_state = 'postprocess'
            @emit @_state
            @_graph.postprocess () =>
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
