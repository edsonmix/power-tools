require 'shelljs/global'
auth = require './auth'
request = require 'request'
paths = require 'path'
util = require './util'

Q = require 'q'

_this = this

start = (name) ->
	deferred = Q.defer()
	credentials = auth.getCredentials()
	requestOptions =
		uri: "http://gallery.vtexlocal.com.br/api/gallery/development/session/start/#{name}"
		headers:
			'cookie': credentials.authCookie.Value
			'x-vtex-account-name': credentials.accountName
			'x-vtex-user-id': credentials.userId

	requestCallBack = (error, response, body) ->
		if response.statusCode isnt 200
			return deferred.reject("Message: #{JSON.parse(body).ExceptionMessage}")

		_this.saveSessions JSON.parse body
		deferred.resolve()

	request.post requestOptions, requestCallBack

	return deferred.promise

exports.saveSessions = (metadata) ->
	sessions = createSessions metadata
	path = util.getAbsoluteFilePath 'sessions/meta.json'
	if !test '-e', path
		util.createFile('sessions/meta.json', sessions)
	else
		updateSessions metadata

updateSessions = (metadata) ->
	path = util.getAbsoluteFilePath 'sessions/meta.json'
	sessions = JSON.parse cat path
	sessions.current = metadata.current
	sessions.sessions = metadata.sessions
	JSON.stringify(sessions).to path

createSessions = (metadata) ->
	json = {}
	json.current = null
	json.sessions = metadata.sessions
	return JSON.stringify(json, null, 4)

getSessionPath = ->
	dir = paths.resolve module.filename, '../../'
	sessions = paths.join(dir, 'sessions')
	sessions if test '-e', sessions

	mkdir '-p', sessions
	return sessions

exports.getSessions = ->
	path = paths.join(getSessionPath(), 'meta.json')
	unless test '-e', path
		throw 'No sessions found. Call \'vtex session start\''

	content = cat path
	return JSON.parse content

exports.init = (command, args) ->
	switch
		when command is 'start'
			throw 'Session must have a name' unless args.length
			startPromise = start(args[0])
			startPromise.then (sessionName) ->
				console.log "Session was created."
			.fail (reason) ->
				console.log reason.red

		else console.log 'command not found. Use vtex session --help'.green
