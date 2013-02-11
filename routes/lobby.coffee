LobbyController = require "../controllers/lobby"

module.exports =
    load: (socket) ->
        controller = new LobbyController socket

        socket.on "lobby:join", (data) -> controller.join data

        socket.on "lobby:leave", (data) -> controller.leave data
