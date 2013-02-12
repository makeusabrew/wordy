crypto = require "crypto"

class User
    constructor: ->
        return

    isAuthed: ->
        return !!@id

    populate: (data) ->
        @id        = data.id
        @username  = data.username
        @email     = data.email
        @emailHash = crypto.createHash("md5").update(data.email.toLowerCase().trim()).digest("hex")

module.exports = User
