WordList = require "./word_list"

class GameRunner
    constructor: (@io, @game) ->
        @timer = null
        @words = []
        @wordId = 1
        @grid = []
        for x in [0..@game.width]
            @grid[x] = []
            for y in [0..@game.height]
                @grid[x][y] = 0

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

        word = @getRandomWordAndPosition()

        return if word is null

        word.claimed = false
        word.userId = null
        word.id = @wordId
        word.flipped = false
        word.rotation = 0

        @wordId += 1

        @words.push word

        data = [word]

        @dirtyGrid word

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

    dirtyGrid: (word) ->
        start = word.x
        len = start + word.size - 1
        for x in [start..len]
            @grid[x][word.y] = word.id

    gridTaken: (word) ->
        start = word.x
        len = start + word.size - 1

        # can't spawn off the grid
        return true if len >= @getWidth()

        for x in [start..len]
            return true if @grid[x][word.y] > 0

        return false

    getRandomWordAndPosition: (attempts = 10) ->
        x = Math.floor(Math.random()*@getWidth())
        y = Math.floor(Math.random()*@getHeight())

        text = WordList.getRandomWord()

        # @todo: un-hardcode 5 below - it's the amount of letters we can fit per tile
        size = Math.ceil(text.length / 5)

        word =
            x: x
            y: y
            text: text
            size: size

        return word if not @gridTaken word

        if attempts
            return @getRandomWordAndPosition(attempts - 1)
        else
            console.log "panic - no slots left"
            return null

module.exports = GameRunner

getRandomDelay = (min = 250) -> min + Math.ceil(Math.random()*7000)
