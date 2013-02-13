BaseController = require "./base"

ChatManager    = require "../managers/chat"

class ChatController extends BaseController
    message: (text) ->
        ChatManager.addMessageFromUser @socket.user, text, (message) =>
            @socket.emitAll "chat:message", message

module.exports = ChatController
