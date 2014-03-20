session = require '../libs/session'
util = require '../libs/util'
assert = require 'assert'

describe "Sessions", ->
  describe "when save session", ->
    after ->
		  util.deleteFile 'sessions/meta.json'

    it "should create file with list of sessions", ->
      #Arrange
      json = {}
      json.sessions = ['store', 'mystore', 'somestore']

      #Act
      session.saveSessions json

      #Assert
      result = session.getSessions()

      assert.equal null, result.currentSession
      assert.equal 'store', result.sessions[0]
      assert.equal 'mystore',result.sessions[1]
      assert.equal 'somestore', result.sessions[2]

    it "should update when sessions already exists", ->
      #Arrange
      json = {}
      json.sessions = ['otherStore', 'otherMystore']

      #Act
      session.saveSessions json

      #Act
      result = session.getSessions()

      #Assert
      assert.equal 'otherStore', result.sessions[0]
      assert.equal 'otherMystore',result.sessions[1]
