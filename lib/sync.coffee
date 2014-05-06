batchWatcher = require './batchWatcher.coffee'
path = require 'path'
fs = require 'fs'
request = require 'request'

hubName = 'DevChangesHub'
signalrEndpoint = 'http://gallery.vtexlocal.com.br/signalr'

exports.start = (accountName, session, user) ->
  console.log 'Starting sync'.grey

  batchWatcher.watch accountName, (batch) ->
    changes = getChanges accountName, batch
    sendChanges accountName, session, user, changes

sendChanges = (accountName, session, user, changes) ->
  payload =
    accountName: accountName
    session: session
    userCookie: user.cookie
    changes: changes
    timeout: 2000

  options =
    url: 'http://gallery.vtexlocal.com.br/api/gallery/development/changes'
    method: 'POST'
    json: payload

  for change in changes
    if change.action is 'update'
      console.log 'U'.yellow + " #{change.path}"
    else if change.action is 'delete'
      console.log 'D'.red + " #{change.path}"
    else
      console.log "#{change.action.grey} #{change.path}"

  request options, (error, response, body) ->
    if response.statusCode is 200
      console.log "... OK"
    else
      console.error 'Status:', response.statusCode


getChanges = (accountName, batch) ->
  root = path.resolve accountName
  for item in batch
      if item.action is 'update'
        try
          data = fs.readFileSync item.path
          item.content = data.toString('base64')
          item.encoding = 'base64'
        catch e
          item.action = 'delete'

      item.path = item.path.substring(root.length + 1).replace(/\\/g, '/')

  batch.filter (item) -> item.action is 'update' || item.action is 'delete'

