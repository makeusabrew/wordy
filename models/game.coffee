WordList = require "./word_list"

class Game
    properties: [
        "id", "minPlayers", "maxPlayers", "started", "width", "height", "finished", "created"
    ]

    constructor: (object) ->
        @fromObject object
        @timer = null
        @words = []
        @wordId = 1
        @grid = {}
        for x in [0..@width-1]
            @grid[x] = {}
            for y in [0..@height-1]
                @grid[x][y] = 0

        @lastWordUserId = 0
        @wordCombo = 1

    fromObject: (object) ->
        @[key] = object[key] for key in @properties

    toObject: ->
        object = {}

        object[key] = @[key] for key in @properties

        object.users = @users

        return object

    emitRoom: (msg, data) ->
        require("../managers/game").io.sockets.in("game:#{@id}").emit msg, data

    start: ->
        @emitRoom "game:start"
        @queueWord()

    queueWord: ->

        clearTimeout @timer

        @timer = setTimeout =>
            @spawnWord()
            @queueWord()
        , getRandomDelay()

    spawnWord: ->

        data = []
        numWords = 1+ Math.floor(Math.random()*3)

        for x in [1..numWords]
            word = @getRandomWordAndPosition()
            if word

                word.claimed = false
                word.userId = null
                word.id = @wordId
                word.flipped = false

                @wordId += 1
                @words.push word

                @dirtyGrid word

                data.push word

        return if data.length is 0

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

        score = @words[index].text.length

        if @lastWordUserId is userId
            # @todo cap combo at some point...
            @wordCombo += 1
        else
            @lastWordUserId = userId
            @wordCombo = 1

        score *= @wordCombo

        callback @words[index].id, score

    dirtyGrid: (word) ->
        v = @getVector word

        for p in [v.start..v.end]
            # horizontal
            if word.rotation % 2 == 0
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
            if word.rotation % 2 == 0
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
            value = @width
        else
            value = @height

        return vector.end < 0 or vector.end >= value

    getRandomWordAndPosition: (attempts = 20) ->
        x = Math.floor(Math.random()*@width)
        y = Math.floor(Math.random()*@height)

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

module.exports = Game

getRandomDelay = (min = 250) -> min + Math.ceil(Math.random()*7000)
