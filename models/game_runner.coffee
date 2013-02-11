class GameRunner
    constructor: (@io, @game) ->
        @timer = null

    emitRoom: (msg, data) ->
        @io.sockets.in("game:#{@game.id}").emit msg, data

    start: ->
        @emitRoom "game:start"
        @queueWord()

    queueWord: ->
        delay = 1000 + Math.ceil(Math.random()*5000)

        clearTimeout @timer
        @timer = setTimeout =>
            x = Math.floor(Math.random()*10)
            y = Math.floor(Math.random()*10)
            word =
                text: "Wordy"
                x: x
                y: y

            data = [word]
            @emitRoom "game:word:spawn", data
            @queueWord()
        , delay

module.exports = GameRunner
