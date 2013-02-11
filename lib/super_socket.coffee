User = require "../models/user"

class SuperSocket
    constructor: (@io, @socket) ->
        @session = @socket.handshake.session
        @user = new User

        @setUser @session.user if @session.user

    setUser: (user) ->
        @user.populate user
        @socket.join "user:#{@user.id}"

    destroyUser: ->
        @user = null
        @session.user = null
        @session.save()

    authUser: (user) ->
        @setUser user

        # if we call this we expect to persist the user to session too, for now
        @session.user = user
        @session.save()

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
