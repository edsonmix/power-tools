prompt = require 'prompt'
auth = require '../libs/auth'

module.exports = (opts) ->
  switch
    when opts.sync then console.log 'sync!'
    when opts.login then auth.userAndPassword()
    when opts.args.length is 0 then opts.help()
    else console.log 'command not found. Use vtex --help'.green
  this
