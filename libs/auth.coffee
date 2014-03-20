qstring = require 'querystring'
request = require 'request'
prompt = require 'prompt'
paths = require 'path'
fs = require 'fs'
Q = require 'q'

authUserAndPassWithVtexId = (credentials) ->
	deferred = Q.defer()
	tokenPromise = getToken()

	authPromise = Q.all([credentials, tokenPromise]).spread (credentials, token) ->
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

getLoginAndPassword = ->
	deferred = Q.defer()
	schema = properties:
		account:
			required: true
		login:
			required: true
		password:
			hidden: true

	prompt.message = 'vtex'
	prompt.delimiter = ':'

	prompt.start()
	console.log "Enter your VTEX credentials\n"
	prompt.get schema, (err, result) ->
		return deferred.reject(result) unless result.login and result.password and result.account
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

getCredentialsPath = ->
	dir = paths.resolve module.filename, '../../'
	credentials = paths.join(dir, 'credentials')
	credentials if test '-e', credentials

	mkdir '-p', credentials
	return credentials

exports.getCredentials = ->
	path = paths.join(getCredentialsPath(), 'data.json')
	unless fs.existsSync(path)
		throw 'Authentication failed. Call \'vtex login\''

	content = fs.readFileSync(path, 'utf8')
	return JSON.parse content

exports.userAndPassword = ->
	loginAndPassPromise = getLoginAndPassword()

	loginAndPassPromise.then (credentials) ->
		authUserAndPassPromise = authUserAndPassWithVtexId(credentials)
		authPromise = Q.all([authUserAndPassPromise, credentials]).spread (response, credentials) ->
			msg = "Authentication: \'#{response.authStatus}\'"
			try
				throw new Error(msg) if response.authStatus isnt 'Success'

				response.userId = credentials.login
				response.accountName = credentials.account

				path = paths.join(getCredentialsPath(), 'data.json')
				fs.writeFile path, JSON.stringify(response, null, 4)

				console.log msg
			catch e
				console.log e.message

		.fail (reason) ->
			new Error("Something went wrong. " + reason.authStatus) if reason isnt 'Success'
