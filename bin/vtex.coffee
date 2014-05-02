program = require 'commander'
pkg = require.main.require '../package.json'
auth = require '../lib/auth.coffee'

program.version pkg.version
  .usage '[command] [options]'

program.command 'sync <account> <session>'
  .description 'synchronize file changes to the development server'
  .action (accountName, session) ->
    console.log "Starting sync to account #{accountName.cyan} and session #{session.cyan}"
    auth.getUser(accountName).then (user) ->
      console.log "Logged in as #{user.login.cyan}"
    .fail (reason) ->
      console.log "Authentication failed: #{reason}".red

program.parse process.argv
