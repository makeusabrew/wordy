GameManager = require "../managers/game"
EventBus    = require "../lib/event_bus"

module.exports =
    load: (io) ->
        gameManager = new GameManager io

        EventBus.on "redis:users:active:sadd", (data) ->
            gameManager.onAddActiveUser data

        EventBus.on "redis:users:active:srem", (data) ->
            gameManager.onRemoveActiveUser data
