WordList = require "./word_list"

class Game
    properties: [
        "id", "minPlayers", "maxPlayers", "started", "width", "height", "finished", "created"
    ]

    constructor: (object) ->
        @fromObject object
        @words = []
        @wordId = 1
        @grid = {}
        @gridList = {}
        @wordOrder = []
        @wordIndex = 0
        @slotsTaken = 0
        @slotsClaimed = 0

        for x in [0..@width-1]
            @grid[x] = {}
            for y in [0..@height-1]
                @grid[x][y] = 0

                offset = (x*@width)+y
                @wordOrder.push(offset)
                @gridList[offset] =
                    x: x
                    y: y
                    free: true
                    sizes: [1, 1, 1, 1]

        @lastWordUserId = 0
        @wordCombo = 1
        @users = []

        # this is a crude implementation of shuffle()... but seems to work well enough
        @wordOrder.sort -> if Math.random() >= 0.5 then -1 else 1

        @calculateGridAvailibility()

    fromObject: (object) ->
        @[key] = object[key] for key in @properties

    toObject: ->
        object = {}

        object[key] = @[key] for key in @properties

        # transient, non persisted stuff
        object.users = @users

        return object

    emitRoom: (msg, data) ->
        require("../managers/game").io.sockets.in("game:#{@id}").emit msg, data

    start: ->
        @started = new Date
        @queueWord getRandomDelay(3000, 5000)

    finish: ->
        @finished = new Date

    queueWord: (delay) ->

        setTimeout =>
            @spawnWord()

            # still not keen on the game handling this logic but can't see
            # how to squeeze it into a controller which doesn't exist
            if @slotsTaken is @width*@height
                # @todo make this something a bit better, obviously
                @emitRoom "game:notification", "The grid is full!"
            else
                @queueWord getRandomDelay()
        , delay

    spawnWord: ->

        data = []
        numWords = 1 + Math.floor(Math.random()*3)

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
                @calculateGridAvailibility()

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

        @slotsClaimed += @words[index].size

        score = @words[index].text.length

        if @lastWordUserId is userId
            @wordCombo += 1 if @wordCombo < 5
        else
            @lastWordUserId = userId
            @wordCombo = 1

        score *= @wordCombo

        result =
            points: score
            combo: @wordCombo
            wordId: @words[index].id
            userId: userId

        callback result

    dirtyGrid: (word) ->
        vector = @getVector word

        @grid[v.x][v.y] = word.id for v in vector

        @slotsTaken += vector.length

    getVector: (object) ->
        vector = []

        if object.rotation % 2 is 0
            start = object.x
        else
            start = object.y

        switch object.rotation
            # right and down are considered positive
            when 0, 1
                end = Math.min(start + (object.size - 1), @width-1)
            # left and up are considered negative
            when 2, 3
                end = Math.max(start - (object.size - 1), 0)

        for p in [start..end]
            v = {}
            if object.rotation % 2 is 0
                v.x = p
                v.y = object.y
            else
                v.x = object.x
                v.y = p

            vector.push v

        return vector

    getRandomWordAndPosition: ->
        # right, what's our ideal next grid slot?
        return null if @slotsTaken is @width*@height

        while @wordIndex < @wordOrder.length
            slot = @gridList[@wordOrder[@wordIndex]]
            break if slot.free

            @wordIndex += 1

        # figure out the max possible word length from here
        # regardless of direction
        max = 0
        max = size if size > max for size in slot.sizes

        # @todo: un-hardcode 5 below - it's the amount of letters we can fit per tile
        # get a word UP TO max length
        text = WordList.getWordUpToLength(max * 5)

        # we need to then convert the word length back down to grid size
        size = Math.ceil(text.length / 5)

        # pick any direction which can house the word
        dir = @getSlotDirection slot, size

        @wordIndex += 1

        word =
            x: slot.x
            y: slot.y
            text: text
            size: size
            rotation: dir

        return word

    calculateGridAvailibility: ->
        @calculateSlotAvailibility slot for key, slot of @gridList

    calculateSlotAvailibility: (slot) ->

        if @grid[slot.x][slot.y] > 0
            slot.free = false
            return

        @calculateSlotSizes slot, dir for dir in [0..3]

    calculateSlotSizes: (slot, dir) ->
        object =
            x: slot.x
            y: slot.y
            rotation: dir
            size: @width

        vector = @getVector object

        free = 0

        for v in vector
            if @grid[v.x][v.y] is 0
                free += 1
            else
                break

        slot.sizes[dir] = free

    getSlotDirection: (slot, size) ->
        # @todo this is a bit foul: all we want to do is pick a direction
        # whose size is >= the grid size of the word we've picked. This could
        # be any of them, regardless of which was the largest etc
        # we pick a random start direction (0-3) and loop through - this
        # ensures we don't bias towards direction 0 (east) etc.
        start = Math.floor(Math.random()*slot.sizes.length)
        for d in [start..start+3]
            direction = d % 4
            return direction if slot.sizes[direction] >= size

    allSlotsClaimed: ->
        return @slotsClaimed is @width*@height

module.exports = Game

# @todo move to utils or something as getRandom(min, max)
getRandomDelay = (min = 250, max = 7000) -> min + Math.ceil(Math.random()*(max-min))
