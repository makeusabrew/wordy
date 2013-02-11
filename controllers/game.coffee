BaseController = require "./base"
GameMapper     = require "../mappers/game"
UserMapper     = require "../mappers/user"

GameManager    = require "../managers/game"

class GameController extends BaseController

    join: (gameId) ->

        gameMapper = new GameMapper

        gameMapper.addUserToGame @socket.getUserId(), gameId, (result) =>

            # @todo either move all temporary state to in-memory like this, or keep it in redis
            @socket.gameId = gameId

            gameMapper.getGameState gameId, (gameStatus) =>

                @socket.emit "game:status", gameStatus

                @socket.emitRoom "game:#{gameId}", "game:user:join", @socket.user

                @socket.join "game:#{gameId}"

                game = gameStatus.game

                # now the user has joined successfully, should we spawn a new game?
                if gameStatus.users.length is game.minPlayers
                    GameManager.startGame game.id, (started) =>
                        @socket.emitAll "game:start", game if started

    submitWord: (word) ->
        # find game id, find game runner, check word
        GameManager.findGame @socket.gameId, (game) =>
            console.log "submit word #{word}"
            
module.exports = GameController
