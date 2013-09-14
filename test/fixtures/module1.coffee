Module = require '../../src/module'

class Module1 extends Module

  process: () ->
    super 'somedata'

module.exports = Module1