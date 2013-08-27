EventEmitter = require('events').EventEmitter

class Graph extends EventEmitter

  constructor: () ->
    @modules = {}
    @links = {}

  start: () ->
    for key, mod of @modules
      do mod.start if mod.config.start

module.exports = Graph      