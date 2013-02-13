BaseController = require "./base"

messages = []

class ChatController extends BaseController
    message: (text) ->
        message =
            user:
                username: @socket.user.username
                id: @socket.getUserId()
            text: text
            created: new Date

        messages.push message

        @socket.emitAll "chat:message", message

module.exports = ChatController
