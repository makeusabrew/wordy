BaseController = require "./base"

messages = []

class ChatController extends BaseController
    message: (data) ->
        messages.push data

        @socket.emitAll "chat:message", data

module.exports = ChatController
