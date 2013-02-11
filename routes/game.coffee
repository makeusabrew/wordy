GameController = require "../controllers/game"

module.exports =
    load: (socket) ->
        controller = new GameController socket

        socket.on "game:join", (data) -> controller.join data

        socket.on "game:word", (data) ->
            return unless socket.gameId
            
            controller.submitWord data
