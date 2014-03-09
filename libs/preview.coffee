globule = require 'globule'
request = require 'request'
watch = require 'watch'
util = require './util'
auth = require './auth'
paths = require 'path'
mime = require 'mime'
fs = require 'fs'
Q = require 'q'

_this = this

changedFiles = {}

onChange = (changedFiles) ->
	deferred = Q.defer()
	requestMessage = _this.createRequestMessage changedFiles
	credentials = auth.getCredentials()

	requestOptions =
		uri: "http://basedevmkp.vtexlocal.com.br:81/api/gallery/v1/development/changes/"
		json: requestMessage
		headers:
			'cookie': credentials.authCookie.Value
			'accountId': credentials.accountId
			'userId': credentials.userId

	requestCallBack = (error, response, body) ->
		throw error if error
		if response.statusCode isnt 200
			return deferred.reject("Invalid status code #{response.statusCode}")
		try
			cleanChangedFiles()
			deferred.resolve()
		catch e
			deferred.reject()

	request.post requestOptions, requestCallBack

	return deferred.promise

syncFilesToS3 = (root) ->
	deferred = Q.defer()
	for file in globule.find(root)
		if fs.lstatSync(file).isFile()
			console.log "sync ", file
			changedFiles[file] = 'created'

	onChange(changedFiles)
	deferred.resolve()
	return deferred.promise

watchFiles = (path) ->
	watch.createMonitor path, (monitor) ->
		monitor.on 'created', (filePath) ->
			console.log "created ", filePath
			addCreatedFile filePath, 'created'
			onChange changedFiles

		monitor.on 'removed', (filePath) ->
			console.log "removed ", filePath
			addRemovedFile filePath, 'removed'

		monitor.on 'changed', (filePath) ->
			console.log "changed", filePath
			changedFiles[filePath] = 'changed'
			onChange changedFiles

addCreatedFile = (filePath, action) ->
	if fs.lstatSync(filePath).isFile()
		changedFiles[filePath] = action

	if fs.lstatSync(filePath).isDirectory()
		for file in fs.readdirSync filePath
			fileName = filePath + "\\" + file
			if fs.lstatSync(fileName).isFile()
				changedFiles[fileName] = action

addRemovedFile = (filePath, action) ->
	if paths.extname(filePath) is ''
		changedFiles[filePath] = action
		onChange(changedFiles)
	else
		if !util.fileAlreadyAdded(changedFiles, filePath, action)
			changedFiles[filePath] = action
			onChange(changedFiles)

exports.createRequestMessage = (changedFiles) ->
	messages = []
	for path in Object.keys changedFiles
		messages.push createJsonForRequest path, changedFiles
	return messages

createJsonForRequest = (path, changedFiles) ->
	action: changedFiles[path]
	path: util.formatPath path
	contentType: mime.lookup path
	content: util.getFileContentBase64 path

cleanChangedFiles = ->
	changedFiles = Object.create null

exports.sync = ->
	credentials = auth.getCredentials()

	root = util.getOptionsFile().root

	changedFiles[root] = 'removed'
	cleanBucketPromise = onChange(changedFiles)

	cleanBucketPromise.then (onChangeReturn) ->
		root = util.getOptionsFile().root
		syncPromise = syncFilesToS3 root

		syncPromise.then (syncReturn) ->
			root = paths.dirname(util.getOptionsFile().root)
			console.log "watching files...".green
			watchFiles(root)

		.fail (reason) ->
			console.log "Something went wrong. ", reason

	.fail (reason) ->
		msg = "Something went wrong. " + reason
		console.log msg.red if reason isnt 'Success'
