Module = require '../../src/module'

class Module2 extends Module

  process: (data) ->
    super data
    
module.exports = Module2