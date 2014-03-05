prompt = require 'prompt'
auth = require '../libs/auth'

module.exports = (opts) ->
  switch
    when opts.sync then console.log 'sync!'
    when opts.login then auth.userAndPassword()

    else 'command not found. Use vtex --help'
  this