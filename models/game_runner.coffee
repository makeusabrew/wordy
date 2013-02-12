WordList = require "./word_list"

class GameRunner
    constructor: (@io, @game) ->
        @timer = null
        @words = []
        @wordId = 1
        @grid = {}
        for x in [0..@game.width]
            @grid[x] = {}
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

        word = @getRandomWordAndPosition()

        return if word is null

        word.claimed = false
        word.userId = null
        word.id = @wordId
        word.flipped = false

        @wordId += 1

        @words.push word

        data = [word]

        @dirtyGrid word

        # we want a controller to pick this up, but the trouble
        # is controllers don't exist until new'd() by a socket
        # this is the only current example of anything other than
        # a controller emitting socket messages: quite tempted to
        # push the queue requests to the client(s)
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
        v = @getVector word

        for p in [v.start..v.end]
            # horizontal
            if word.rotation % 2
                x = p
                y = word.y
            else
                x = word.x
                y = p
            @grid[x][y] = word.id

    gridTaken: (word) ->
        v = @getVector word

        # can't spawn off the grid
        return true if @offGrid v

        for p in [v.start..v.end]
            # horizontal
            if word.rotation % 2
                x = p
                y = word.y
            else
                x = word.x
                y = p
            return true if @grid[x][y] > 0

        return false

    getVector: (word) ->
        vector =
            rotation: word.rotation

        if word.rotation % 2 == 0
            start = word.x
        else
            start = word.y

        switch word.rotation
            # right and down are considered positive
            when 0, 1
                end = start + (word.size - 1)
            # left and up are considered negative
            when 2, 3
                end = start - (word.size - 1)

        vector.start = start
        vector.end = end

        return vector

    offGrid: (vector) ->
        # horizontal; only care about X
        if vector.rotation % 2 is 0
            fn = @getWidth
        else
            fn = @getHeight

        return vector.end < 0 or vector.end >= fn.apply this

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
            rotation: Math.floor(Math.random()*4)

        return word if not @gridTaken word

        if attempts
            return @getRandomWordAndPosition(attempts - 1)
        else
            console.log "panic - no slots left"
            return null

module.exports = GameRunner

getRandomDelay = (min = 250) -> min + Math.ceil(Math.random()*7000)
