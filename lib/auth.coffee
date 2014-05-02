prompt = require 'prompt'
path = require 'path'
fs = require 'fs'
Q = require 'Q'
request = require 'request'

exports.getUser = (accountName) ->
  deferred = Q.defer()

  user = getStoredUser accountName
  if user
    deferred.resolve user
  else
    askForCredentials(accountName).then (credentials) ->
      authPromise = getToken().then (token) ->
        authenticate(accountName, credentials.login, credentials.password, token).then (response) ->
          if response.authStatus isnt 'Success'
            deferred.reject response.authStatus
          else
            user = storeUser accountName,
              login: credentials.login
              id: response.userId,
              cookie: response.authCookie.Value
            deferred.resolve user
        .fail (reason) ->
          deferred.reject reason

    .fail (reason) ->
      deferred.reject reason

  deferred.promise

getStoredUser = (accountName) ->
  filePath = path.resolve module.filename, '../../tmp/credentials.json'
  return undefined unless fs.existsSync filePath

  content = fs.readFileSync filePath, 'utf8'
  credentials = JSON.parse content
  credentials[accountName]

storeUser = (accountName, user) ->
  dirPath = path.resolve module.filename, '../../tmp'
  filePath = dirPath + '/credentials.json'
  unless fs.existsSync dirPath
    fs.mkdirSync dirPath
  if fs.existsSync filePath
    content = fs.readFileSync filePath, 'utf8'
    credentials = JSON.parse content
  else
    credentials = {}

  credentials[accountName] = user
  content = JSON.stringify credentials, null, 2
  fs.writeFileSync filePath, content
  user

askForCredentials = (accountName) ->
  deferred = Q.defer()
  options =
    properties:
      login: required: true
      password: required: true, hidden:true

  prompt.message = '> '
  prompt.delimiter = ''

  prompt.start()
  console.log "Log in to account '#{accountName}' with your VTEX credentials"

  prompt.get options, (err, result) ->
    if result.login and result.password then deferred.resolve result
    else deferred.reject result

  deferred.promise

getToken = () ->
  deferred = Q.defer()

  requestOptions =
    uri: "https://vtexid.vtex.com.br/api/vtexid/pub/authentication/start"

  request requestOptions, (error, response, body) ->
    if error then deferred.reject error
    if response.statusCode isnt 200
      console.log JSON.parse(body).error
      deferred.reject "Invalid status code #{response.statusCode}"

    try
      token = JSON.parse(body).authenticationToken
      deferred.resolve token
    catch
      deferred.reject 'Invalid JSON while getting token from VTEX ID'

  deferred.promise

authenticate = (accountName, login, password, token) ->
  deferred = Q.defer()

  requestOptions =
    uri: "https://vtexid.vtex.com.br/api/vtexid/pub/authentication/classic/validate" +
      "?authenticationToken=#{encodeURIComponent(token)}" +
      "&login=#{encodeURIComponent(login)}" +
      "&password=#{encodeURIComponent(password)}"

  request requestOptions, (error, response, body) ->
    if error then deferred.reject error
    if response.statusCode isnt 200
      console.log JSON.parse(body).error
      deferred.reject "Invalid status code #{response.statusCode}"

    try
      deferred.resolve JSON.parse(body)
    catch 
      deferred.reject "Invalid JSON while authenticating with VTEX ID"

  deferred.promise
