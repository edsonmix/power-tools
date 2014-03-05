qstring = require 'querystring'
request = require 'request'
prompt = require 'prompt'
fs = require 'fs'
Q = require 'q'

authUserAndPassWithVtexId = ->
	deferred = Q.defer()
	credentialsPromise = getCredentials()
	tokenPromise = getToken()

	authPromise = Q.all([credentialsPromise, tokenPromise]).spread (credentials, token) ->
		authUserWith(credentials.login, credentials.password, token)

	authPromise.then (success) ->
		return deferred.resolve(success)

	authPromise.fail (reason) ->
		return deferred.reject(reason)

	return deferred.promise

getToken = ->
	deferred = Q.defer()

	requestOptions =
		uri: "https://vtexid.vtex.com.br/api/vtexid/pub/authentication/start"

	requestCallback = (error, response, body) ->
		if response.statusCode isnt 200
			return deferred.reject("Invalid status code #{response.statusCode}")
		try
			token = JSON.parse(body).authenticationToken
			deferred.resolve(token)
		catch
			deferred.reject("Invalid JSON!")

	request requestOptions, requestCallback

	return deferred.promise

getCredentials = ->
	deferred = Q.defer()
	schema = properties:
		login:
			required: true
		password:
			hidden: true

	prompt.message = 'vtex'
	prompt.delimiter = ':'

	prompt.start()
	console.log "Enter your VTEX credentials\n"
	prompt.get schema, (err, result) ->
		return deferred.reject(result) unless result.login and result.password
		return deferred.resolve(result)

	return deferred.promise

authUserWith = (login, password, token) ->
	deferred = Q.defer()

	requestOptions =
		uri: "https://vtexid.vtex.com.br/api/vtexid/pub/authentication/classic/validate?authenticationToken=#{encodeURIComponent(token)}&login=#{encodeURIComponent(login)}&password=#{encodeURIComponent(password)}"

	requestCallback = (error, response, body) ->
		throw error if error
		if response.statusCode isnt 200
			console.log JSON.parse(body).error
			deferred.reject("Invalid status code #{response.statusCode}")
		try
			deferred.resolve(JSON.parse(body))
		catch
			deferred.reject("Invalid JSON!")

	request requestOptions, requestCallback

	return deferred.promise

exports.userAndPassword = ->
	authPromise = authUserAndPassWithVtexId()
	authPromise.then (response) ->
		msg = "Authentication: \'#{response.authStatus}\'"
		try
			throw new Error(msg) if response.authStatus isnt 'Success'

			fs.writeFile 'credentials.json', JSON.stringify(response, null, 4)
			console.log msg
		catch e
			console.log e.message

	.fail (reason) ->
		new Error("Something went wrong. " + reason.authStatus) if reason isnt 'Success'
