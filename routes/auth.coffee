AuthController = require "../controllers/auth"

module.exports =
    load: (socket) ->
        authController = new AuthController socket

        socket.on "auth:login", (data) -> authController.login data

        socket.on "auth:register", (data) -> authController.register data

        # special route triggered when a client leaves (obviously)
        # the point is, we don't explicitly emit this from the client
        # side; socket.io takes care of all that for us
        socket.on "disconnect", ->
            return if not socket.getUserId()

            authController.disconnect()
