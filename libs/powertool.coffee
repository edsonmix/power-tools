prompt = require 'prompt'
auth = require '../libs/auth'
preview = require '../libs/preview'
session = require '../libs/session'

module.exports = (opts) ->
  switch
    when opts.preview then preview.sync()
    when opts.login then auth.userAndPassword()
    when opts.session then session.init(opts.session, opts.args)
    when opts.args.length is 0 then opts.help()
    else console.log 'command not found. Use vtex --help'.green
  this
