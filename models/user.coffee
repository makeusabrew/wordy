crypto = require "crypto"

class User
    properties: [
        "id", "username", "email", "password"
    ]

    constructor: ->
        return

    isAuthed: ->
        return !!@id

    fromObject: (object) ->
        @[key] = object[key] for key in @properties

    toObject: ->
        object = {}

        object[key] = @[key] for key in @properties

        object.emailHash = crypto.createHash("md5").update(@email.toLowerCase().trim()).digest("hex")

        return object

module.exports = User
