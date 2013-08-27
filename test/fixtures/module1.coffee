Module = require '../../src/module'

class Module1 extends Module

  process: (data) ->
    super data

  start: () ->
    @process 'somedata'

module.exports = Module1