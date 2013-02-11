Bus = require "../lib/event_bus"

class GameRunner
    constructor: (@io, @game) ->
        @timer = null
        @words = []
        @wordId = 1

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
            claimed: false
            userId: null
            id: @wordId

        @wordId += 1

        @words.push word

        data = [word]

        # we want a controller to pick this up, but the trouble
        # is controllers don't exist until new'd() by a socket
        @emitRoom "game:word:spawn", data

    findWord: (input, callback) ->
        for word, i in @words when word.claimed is false
            if word.text.toLowerCase() is input.toLowerCase()
                return callback word, i

        callback false, -1
    
    claimWord: (userId, index, callback) ->
        @words[index].claimed = true
        @words[index].userId = userId

        # @todo run through score logic
        score = @words[index].text.length
        callback @words[index].id, score

module.exports = GameRunner

getRandomDelay = (min = 1000) -> min + Math.ceil(Math.random()*5000)
