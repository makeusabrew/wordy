bcrypt = require "bcrypt"

class User
    constructor: ->
        return

    isAuthed: ->
        return !!@id

    populate: (data) ->
        @id       = data.id
        @username = data.username

module.exports = User
