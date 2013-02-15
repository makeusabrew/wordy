BaseController = require "./base"

GameManager    = require "../managers/game"
UserManager    = require "../managers/user"
ChatManager    = require "../managers/chat"

class LobbyController extends BaseController
    join: (data) ->
        # well, we *have* to join the lobby...
        UserManager.addToLobby @socket.user, =>
            # let everyone else in the room know the new user is present
            @socket.emitRoom "lobby", "lobby:user:join", @socket.user.toObject()

            # add the chat line
            ChatManager.addNotification "#{@socket.user.username} has entered the lobby", (message) =>
                @socket.emitAll "chat:message", message

                getLobbyState (data) =>

                    # let the user know the current crack
                    @socket.emit "lobby:status", data

                    # need this last otherwise socket will get both messages
                    @socket.join "lobby" # perhaps...

                    GameManager.checkSpawnNewGame (game) =>
                        @socket.emitAll "game:spawn", game.toObject() if game

    leave: ->
        UserManager.removeFromLobby @socket.user, =>
            @socket.leave "lobby"
            @socket.emitRoom "lobby", "lobby:user:leave", @socket.user.toObject()

module.exports = LobbyController

getLobbyState = (callback)->
    # we have to get the games...
    GameManager.findAllActive (games) =>
        # and, well, we need to get the list of lobby users
        UserManager.findAllLobby (users) =>
            # and we need some chat info...
            ChatManager.getMessages 10, (messages) =>

                # simplify the user classes into friendly objects
                users = (user.toObject() for user in users)

                data =
                    users: users
                    games: games
                    messages: messages

                callback data
