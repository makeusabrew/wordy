crypto = require "crypto"

class User
    properties: [
        "id", "username", "email", "password"
    ]

    constructor: ->
        @gameScore = 0

    isAuthed: ->
        return !!@id

    fromObject: (object) ->
        @[key] = object[key] for key in @properties

    toObject: ->
        object = {}

        object[key] = @[key] for key in @properties

        delete object.password

        object.emailHash = crypto.createHash("md5").update(@email.toLowerCase().trim()).digest("hex")
        object.score = @gameScore

        return object

module.exports = User
