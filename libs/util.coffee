require 'shelljs/global'
defaultOptions = require './default_options'
extend = require 'node.extend'
globToRegExp = require 'glob-to-regexp'
paths = require 'path'
yaml = require 'js-yaml'

_this = this

getPatternFrom = (key) ->
	key = key.replace /\\/g, "\\/\\"
	return pattern = /// ^(#{key}\/) ///

getOnlyDirectories = (changedFiles, action) ->
	directories = []
	for key, value of changedFiles
		if value is action
			directories.push key if paths.extname(key) is ''
	return directories

defaultConfigs = (options) ->
	config = extend(true, {}, defaultOptions, options)
	return config

exports.getOptionsFile = ->
	possibleFiles = [
		"_powertool.yaml"
		"_powertool.yml"
		"_powertool.json"
	]
	i = 0
	while i < possibleFiles.length
		name = possibleFiles[i]
		if test("-e", name)
			return defaultConfigs(yaml.safeLoad(cat(name)))
		i++

	throw new Error('File \'_powertool.yaml\' not found.')

exports.fileAlreadyAdded = (changedFiles, filePath, action) ->
	for file in getOnlyDirectories changedFiles, action
		pattern = getPatternFrom(this.formatPath(file))
		return true if pattern.test(filePath) is true
	return false

exports.getFileContentBase64 = (path) ->
	if test '-f', path
		content = cat path
		return new Buffer(content || '').toString('base64')

exports.formatPath = (file) ->
	return file.replace /\\/g,"\/"

exports.shouldIgnore = (file) ->
	opts = _this.getOptionsFile()
	for opts in opts.ignore
		regex = globToRegExp(opts)
		return true if regex.test _this.formatPath(file)
	return false

exports.createFile = (filename, data) ->
	path = _this.getAbsoluteFilePath filename
	dirname = paths.dirname path
	mkdir dirname if !test '-e', dirname
	data.to path

exports.deleteFile = (filename) ->
	path = _this.getAbsoluteFilePath filename
	rm '-rf', path if test '-e', path

exports.getAbsoluteFilePath = (filename) ->
	dir = paths.resolve module.filename, '../../'
	return paths.join dir, filename
