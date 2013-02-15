BaseController = require "./base"
GameManager    = require "../managers/game"
ChatManager    = require "../managers/chat"

class GameController extends BaseController

    join: (gameId) ->

        GameManager.findGame gameId, (game) =>

            # @todo either move all temporary state to in-memory like this, or keep it in redis
            @socket.game = game

            GameManager.addUserToGame @socket.user, game, =>

                # @todo we need to figure out a neat way of notifying lobby users too
                # as they will care that a user has joined / left
                # and also whether a game has started or not too
                @socket.emit "game:status", game.toObject()

                @socket.emitRoom "game:#{gameId}", "game:user:join", @socket.user.toObject()

                @socket.join "game:#{gameId}"

                # now the user has joined successfully, should we spawn a new game?
                GameManager.canStartGame game, (started) =>
                    return if not started

                    # below is ignored but will probably be re-instated at some point
                    #@socket.emitAll "game:start", game.toObject() if started

                    ChatManager.addNotification "Game ##{game.id} started!", (message) =>
                        @socket.emitAll "chat:message", message

    submitWord: (text) ->
        GameManager.claimWord @socket.game, @socket.user, text, (result) =>
            return if not result

            # well done! let everyone know
            # the result object is safe to pass straight through
            @socket.emitRoom "game:#{@socket.game.id}", "game:word:claim", result

            GameManager.allSlotsClaimed @socket.game, (claimed) =>
                return if not claimed

                GameManager.finishGame @socket.game, =>
                    @socket.emitRoom "game:#{@socket.game.id}", "game:over"

module.exports = GameController
