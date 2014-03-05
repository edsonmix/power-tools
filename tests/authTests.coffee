require 'shelljs/global'
aux = require './test'
auth = require '../libs/auth'
assert = require 'assert'
paths = require 'path'

describe "Authentication", ->
  afterEach ->
    aux.deleteFile 'credentials/data.json'

  describe "credentials", ->
    it "should return json when the credentials file exists", ->
      #Arrange
      json =
      """
      {
        "authStatus": "Success",
        "clientToken": null,
        "authCookie": {
            "Name": "cookie",
            "Value": "ABCD"
        },
        "userId": "1234",
        "scope": null
      }
      """
      aux.createFile 'credentials/data.json', json

      #Act
      credentials = auth.getCredentials()

      #Assert
      assert.equal 'Success', credentials.authStatus
      assert.equal null, credentials.clientToken
      assert.equal 'cookie', credentials.authCookie.Name
      assert.equal 'ABCD', credentials.authCookie.Value
      assert.equal '1234', credentials.userId
      assert.equal null, credentials.scope