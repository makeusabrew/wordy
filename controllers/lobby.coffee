BaseController = require "./base"

GameManager    = require "../managers/game"
UserManager    = require "../managers/user"

class LobbyController extends BaseController
    join: (data) ->
        # well, we *have* to join the lobby...
        UserManager.addToLobby @socket.user, =>
            # and we have to get the games too...
            GameManager.findAllActive (games) =>
                # and, well, we need to get the list of lobby users
                UserManager.findAllLobby (users) =>

                    data =
                        users: users
                        games: games

                    # let the user know the current crack
                    @socket.emit "lobby:status", data

                    # let everyone else in the room know it too
                    @socket.emitRoom "lobby", "lobby:user:join", @socket.user

                    # need this last otherwise socket will get both messages
                    @socket.join "lobby" # perhaps...

                    GameManager.checkSpawnNewGame (game) =>
                        @socket.emitAll "game:spawn", game.toObject() if game

    leave: ->
        UserManager.removeFromLobby @socket.user, =>
            @socket.leave "lobby"
            @socket.emitRoom "lobby", "lobby:user:leave", @socket.user

module.exports = LobbyController
