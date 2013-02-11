ChatController = require "../controllers/chat"

module.exports =
    load: (socket) ->
        controller = new ChatController socket

        socket.on "chat:message", (data) -> controller.message data
