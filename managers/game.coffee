GameMapper  = require "../mappers/game"
UserManager = require "./user"
Game        = require "../models/game"

timers = {}
games = {}

# @todo move this config stuff elsewhere
MAX_UNCLAIMED_TILES = 10
MAX_TIME_GAP = 7000

GameManager =
    io: null

    addActive: (game, callback) ->
        games[game.id] = game
        timers[game.id] = null
        callback()

    countAllActive: (callback) ->
        count = 0
        count += 1 for game of games

        callback count

    findAllActive: (callback) ->
        flat = (game.toObject() for key, game of games)
        callback flat

    addUserToGame: (user, game, callback) ->

        game.addUser user

        callback()

    removeUserFromGame: (user, game, callback) ->

        game.removeUser user

        callback()

    findUsers: (id, callback) ->
        callback game[id].users

    checkSpawnNewGame: (callback) ->

        UserManager.countAllActive (numUsers) =>
            @countAllActive (numGames) =>
                # @todo do some clever stuff on users Vs games, for now just spawn
                data =
                    created: new Date
                    started: null
                    finished: null
                    minPlayers: 1
                    maxPlayers: 8
                    width: 10
                    height: 10

                (new GameMapper).create data, (object) =>
                    # augment the game into a proper model
                    game = new Game(object)
                    @addActive game, => callback game

    findGame: (id, callback) ->
        return callback null if not games[id]

        callback games[id]

    claimWord: (game, user, text, callback) ->
        result = game.claimWord user, text

        # word looks good, no timer present and space on the grid - queue one!
        if result and not timers[game.id] and game.unclaimedTileCount() < MAX_UNCLAIMED_TILES
            timeGap = (new Date) - game.lastSpawnTime
            timeLeft = Math.max(1000, MAX_TIME_GAP - timeGap)

            @queueWord game, getRandomDelay(250, timeLeft)

        callback result

    canStartGame: (game, callback) ->
        if game.users.length >= game.minPlayers and not game.started

            game.start()

            @startCountdown game

            return callback true

        callback false

    allSlotsClaimed: (game, callback) ->
        callback game.allSlotsClaimed()

    finishGame: (game, callback) ->
        callback false if game.finished

        game.finish()
        callback true

    queueWord: (game, delay) ->
        return if timers[game.id]

        timers[game.id] = setTimeout =>
            timers[game.id] = null
            timer = null

            numWords = 1 + Math.floor(Math.random()*3)
            words = game.spawnWords numWords
            @emitGame game, "game:word:spawn", words if words.length

            if game.isGridFull()
                # @todo make this something a bit better, obviously
                return @emitGame game, "game:notification", "The grid is full!"

            # only queue more words if there aren't too many already
            if game.unclaimedTileCount() < MAX_UNCLAIMED_TILES
                return @queueWord game, getRandomDelay()
        , delay

    emitGame: (game, msg, data) ->
        @io.sockets.in("game:#{game.id}").emit msg, data

    startCountdown: (game) ->
        # @see https://github.com/makeusabrew/wordy/issues/13
        # crude as you like, but okay for now
        setTimeout =>
            @emitGame game, "game:countdown", "3"
        , 1000

        setTimeout =>
            @emitGame game, "game:countdown", "2"
        , 2000

        setTimeout =>
            @emitGame game, "game:countdown", "1"
        , 3000

        setTimeout =>
            @emitGame game, "game:countdown", "Go!"
            @queueWord game, getRandomDelay(3000, 5000)
        , 4000

module.exports = GameManager

# @todo move to utils or something as getRandom(min, max)
getRandomDelay = (min = 250, max = 7000) -> min + Math.ceil(Math.random()*(max-min))
