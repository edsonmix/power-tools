require 'shelljs/global'
defaultOptions = require './default_options'
extend = require 'node.extend'
paths = require 'path'
yaml = require 'js-yaml'

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