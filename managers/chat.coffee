#Message = require "../models/chat"

messages = []

ChatManager =
    user:
        username: "chatbot"
        id: -1

    addMessageFromUser: (user, text, callback) ->
        message =
            text: text
            created: new Date
            user:
                username: user.username
                id: user.id

        messages.push message

        # for now we're just using basic objects
        callback message

    addNotification: (text, callback) ->
        @addMessageFromUser @user, text, callback

    getMessages: (limit, callback) ->
        callback messages.slice(-limit)

module.exports = ChatManager
