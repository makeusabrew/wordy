BaseController = require "./base"
GameManager    = require "../managers/game"

class GameController extends BaseController

    join: (gameId) ->

        GameManager.findGame gameId, (game) =>

            # @todo either move all temporary state to in-memory like this, or keep it in redis
            @socket.gameId = gameId

            GameManager.addUserToGame @socket.user, game, =>

                # @todo we need to figure out a neat way of notifying lobby users too
                # as they will care that a user has joined / left
                # and also whether a game has started or not too
                @socket.emit "game:status", game.toObject()

                @socket.emitRoom "game:#{gameId}", "game:user:join", @socket.user

                @socket.join "game:#{gameId}"

                # now the user has joined successfully, should we spawn a new game?
                GameManager.canStartGame game, (started) =>
                    # this message below is currently ignored client side...
                    @socket.emitAll "game:start", game.toObject() if started

    submitWord: (word) ->
        GameManager.claimWord @socket.gameId, @socket.getUserId(), word, (wordId, score) =>
            if score
                # well done! let everyone know
                data =
                    wordId: wordId
                    score: score
                    userId: @socket.getUserId()

                @socket.emitRoom "game:#{@socket.gameId}", "game:word:claim", data
module.exports = GameController
