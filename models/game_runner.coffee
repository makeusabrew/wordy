Bus = require "../lib/event_bus"

class GameRunner
    constructor: (@io, @game) ->
        @timer = null

    emitRoom: (msg, data) ->
        @io.sockets.in("game:#{@game.id}").emit msg, data

    start: ->
        @emitRoom "game:start"
        @queueWord()

    getWidth: ->
        @game.width

    getHeight: ->
        @game.height

    queueWord: ->

        clearTimeout @timer

        @timer = setTimeout =>
            @spawnWord()
            @queueWord()
        , getRandomDelay()

    spawnWord: ->
        # @todo...
        # first we need to check what slots we have available
        # so that we don't pick a word which is far too big
        # to fit in the remaining space

        x = Math.floor(Math.random()*@getWidth())
        y = Math.floor(Math.random()*@getHeight())

        word =
            text: "Wordy"
            x: x
            y: y

        data = [word]

        # we want a controller to pick this up, but the trouble
        # is controllers don't exist until new'd() by a socket
        @emitRoom "game:word:spawn", data

module.exports = GameRunner

getRandomDelay = (min = 1000) -> min + Math.ceil(Math.random()*5000)
