util = require '../libs/util'
assert = require 'assert'
aux = require './test'

describe "when add a removed file to changedFiles", ->

 it "should return true if root folder already added", ->
	#Arrange
	changedFiles = {}
	changedFiles['path/to'] = 'removed'
	changedFiles['path/to/file.txt'] = 'removed'

	#Act
	result = util.fileAlreadyAdded(changedFiles, 'path/to/file.txt', 'removed')

	#Assert
	assert.equal true, result

 it "should return false if root folder don't exists", ->
	#Arrange
	changedFiles = {}
	changedFiles['path/to'] = 'removed'

	#Act
	result = util.fileAlreadyAdded(changedFiles, 'path/other/file.txt', 'removed')

	#Assert
	assert.equal false, result

describe "when getOptionsFile ", ->
	afterEach ->
		aux.deleteFile '_powertool.yml'

	it "should return configs if options file exists", ->
		#Arrange
		yml =
		"""
		root: root/**
		ignore: [some/path/*.js]
		"""
		aux.createFile '_powertool.yml', yml

		#Act
		config = util.getOptionsFile()

		#Assert
		assert.equal 'root/**', config.root
		assert.equal 'some/path/*.js', config.ignore[0]

	it "should throw error if options file don't exists", ->
		#Arrange & Act
		err = util.getOptionsFile

		#Assert
		assert.throws(err, Error, "File \'_powertool.yaml\' not found.")

	it "should return default options in the empty fields", ->
		#Arrange
		yml =
		"""
		root: root/**
		"""
		aux.createFile '_powertool.yml', yml

		#Act
		config = util.getOptionsFile()

		#Assert
		assert.equal 'root/**', config.root
		assert.equal 0, config.ignore.length

describe "when add file to changedFiles", ->
	afterEach ->
		aux.deleteFile '_powertool.yml'

	it "should return true if matches to ignore files", ->
		#Arrange
		yml =
		"""
		ignore: ['some/path/*.txt']
		"""
		aux.createFile '_powertool.yml', yml

		#Act
		result = util.shouldIgnore 'some/path/to/file.txt'

		#Assert
		assert.equal true, result

	it "should return false if don't matches to ignore files", ->
		#Arrange
		yml =
		"""
		ignore: ['some/path/*.txt']
		"""
		aux.createFile '_powertool.yml', yml

		#Act
		result = util.shouldIgnore 'file.txt'

		#Assert
		assert.equal false, result