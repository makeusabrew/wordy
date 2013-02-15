SuperSocket = require "../lib/super_socket"

module.exports = (io) ->

    # could load global routes here which require an over-arching controller instance?

    return (socket) ->

        # normal sockets don't quite cut it; let's package them up with the global
        # socket.io object as an added bonus
        superSocket = new SuperSocket io, socket

        # we want the client to know the auth state
        # as soon as they connect
        socket.emit "auth:init", superSocket.user

        # @todo we should only load certain groups of routes based on
        # whether a user is authed or not. We'll need more fine grained
        # control within route files too, but we can ignore whole files
        # sometimes - except of course a socket can auth *after* it joins!
        require("./auth").load superSocket

        require("./lobby").load superSocket
        require("./game").load superSocket
        require("./chat").load superSocket
