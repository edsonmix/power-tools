auth = require './auth'

exports.sync = ->
	credentials = auth.getCredentials()
	throw new Error('Authentication failed. Call \'vtex login\'') if credentials is null