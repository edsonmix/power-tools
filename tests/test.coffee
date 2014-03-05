require 'shelljs/global'
paths = require 'path'

exports.deleteFile = (filename) ->
	dir = paths.resolve module.filename, '../../'
	path = paths.join dir, filename
	rm '-rf', path if test '-e', path

exports.createFile = (filename, data) ->
	dir = paths.resolve module.filename, '../../'
	path = paths.join dir, filename
	dirname = paths.dirname filename

	mkdir dirname if !test '-e', dirname

	data.to path

