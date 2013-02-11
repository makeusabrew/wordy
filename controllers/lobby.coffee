BaseController = require "./base"
GameMapper     = require "../mappers/game"
UserMapper     = require "../mappers/user"

GameManager    = require "../managers/game"

class LobbyController extends BaseController
    join: (data) ->
        gameMapper = new GameMapper
        userMapper = new UserMapper

        # too much redis?

        # well, we *have* to join the lobby...
        userMapper.addToLobby @socket.getUserId(), (result) =>
            # and we have to get the games too...
            gameMapper.findAllActive (games) =>
                # and, well, we need to get the list of lobby users
                userMapper.findAllLobby (users) =>

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
                        @socket.emitAll "game:spawn", game if game

    leave: ->
        new UserMapper().removeFromLobby @socket.getUserId(), (result) =>
            @socket.leave "lobby"
            @socket.emitRoom "lobby", "lobby:user:leave", @socket.user

module.exports = LobbyController
