WordList = require "./word_list"

class Game
    properties: [
        "id", "minPlayers", "maxPlayers", "started", "width", "height", "finished", "created"
    ]

    constructor: (object) ->
        @fromObject object if object
        @words = []
        @wordId = 1
        @grid = {}
        @gridList = {}
        @wordOrder = []
        @wordIndex = 0
        @slotsTaken = 0
        @slotsClaimed = 0
        @lastSpawnTime = 0

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
        @winner = null

        # this is a crude implementation of shuffle()... but seems to work well enough
        @wordOrder.sort -> if Math.random() >= 0.5 then -1 else 1

        @calculateGridAvailibility()

    fromObject: (object) ->
        @[key] = object[key] for key in @properties

    toObject: ->
        object = {}

        object[key] = @[key] for key in @properties

        # transient, non persisted stuff
        object.users = (user.toObject() for user in @users)
        object.winner = @winner.toObject() if @winner

        return object


    start: ->
        @started = new Date

    finish: ->
        @finished = new Date

        @users.sort (a, b) ->
            return  1 if a.gameScore < b.gameScore
            return -1 if a.gameScore > b.gameScore
            return  0

        @winner = @users[0]

    spawnWords: (numWords) ->

        data = []

        for x in [1..numWords]
            break if @slotsTaken is @width*@height

            data.push @getRandomWordAndPosition()

        return data

    findWord: (text) ->
        for word, i in @words when word.claimed is false
            return word if word.text.toLowerCase() is text.toLowerCase()

        return null
    
    claimWord: (user, text) ->
        word = @findWord text

        return null if not word

        word.claimed = true
        word.userId = user.id

        @slotsClaimed += word.size

        score = word.text.length

        if @lastWordUserId is user.id
            @wordCombo += 1 if @wordCombo < 5
        else
            @lastWordUserId = user.id
            @wordCombo = 1

        score *= @wordCombo

        user.gameScore += score

        # @todo can we just augment the word here?
        # that way we can easily store relevant stuff
        # in one place
        result =
            points: score
            currentScore: user.gameScore
            combo: @wordCombo
            wordId: word.id
            userId: user.id

        return result

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

        slot = @getNextFreeSlot()

        # figure out the max possible word length from here
        # regardless of direction
        # @todo store this against the slot instead
        max = 0
        max = size if size > max for size in slot.sizes

        # @todo: un-hardcode 5 below - it's the amount of letters we can fit per tile
        # get a word UP TO max length
        text = WordList.getWordUpToLength(max * 5)

        @spawnWordAtSlot text, slot

    spawnWordAtSlot: (text, slot) ->

        # we need to convert the word length back down to grid size
        size = Math.ceil(text.length / 5)

        # pick any direction which can house the word
        dir = @getSlotDirection slot, size

        word =
            x: slot.x
            y: slot.y
            text: text
            size: size
            rotation: dir
            claimed: false
            userId: null
            id: @wordId

        @wordId += 1

        @words.push word

        @dirtyGrid word

        @calculateGridAvailibility()

        @lastSpawnTime = new Date

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

    addUser: (user) ->
        # well, a new user can't have any points yet
        # need to think about the ramifications of this - given that
        # ultimately this probably changes the @socket.user object,
        # probably only relevant in edge cases of multiple games at once etc
        user.gameScore = 0
        @users.push user

    removeUser: (user) ->
        return @users.splice i, 1 for u, i in @users when u.id is user.id

    isGridFull: ->
        @slotsTaken is @width*@height

    unclaimedTileCount: ->
        @slotsTaken - @slotsClaimed

    getNextFreeSlot: ->
        while @wordIndex < @wordOrder.length
            slot = @gridList[@wordOrder[@wordIndex]]
            @wordIndex += 1

            return slot if slot.free

module.exports = Game
