User = require "../models/user"

class SuperSocket
    constructor: (@io, @socket) ->
        @user = new User

    setUser: (user) ->
        @user.populate user
        @socket.join "user:#{@user.id}"

    destroyUser: ->
        @user = null

    authUser: (user) ->
        @setUser user

    on: (msg, data) ->
        @socket.on msg, data

    emit: (msg, data) ->
        @socket.emit msg, data

    emitUser: (msg, data) ->
        @io.sockets.in("user:#{@user.id}").emit msg, data

    emitRoom: (room, msg, data) ->
        @io.sockets.in(room).emit msg, data

    emitAll: (msg, data) ->
        @io.sockets.emit msg, data

    join: (room) ->
        @socket.join room

    leave: (room) ->
        @socket.leave room

    getUserId: -> @user.id

module.exports = SuperSocket
