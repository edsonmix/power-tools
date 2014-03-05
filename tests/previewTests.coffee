preview = require '../libs/preview'
assert = require 'assert'
aux = require './test'

describe "when create a request message", ->
 afterEach ->
	aux.deleteFile 'file.txt'

 it "should return array with jsons", ->
	#Arrange
	changedFiles = {}
	changedFiles['file.txt'] = 'removed'

	aux.createFile 'file.txt', 'some content'

	#Act
	message = preview.createRequestMessage changedFiles

	#Assert
	assert.equal 'removed', message[0].action
	assert.equal  'file.txt', message[0].path
	assert.equal  'text/plain', message[0].contentType
	assert.equal 'c29tZSBjb250ZW50', message[0].content