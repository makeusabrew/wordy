BaseController = require "./base"
GameMapper     = require "../mappers/game"
UserMapper     = require "../mappers/user"

GameRunner     = require "../models/game_runner"

class GameController extends BaseController

    join: (gameId) ->

        gameMapper = new GameMapper

        gameMapper.addUserToGame @socket.getUserId(), gameId, (result) =>
            gameMapper.getGameState gameId, (gameStatus) =>

                @socket.emit "game:status", gameStatus

                @socket.emitRoom "game:#{gameId}", "game:user:join", @socket.user

                @socket.join "game:#{gameId}"

                game = gameStatus.game

                # now the user has joined successfully, should we spawn a new game?
                # @todo un-hardcode, of course...
                if gameStatus.users.length is game.minPlayers
                    runner = new GameRunner @socket.io, game
                    runner.start()

module.exports = GameController
