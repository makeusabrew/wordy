GameMapper  = require "../mappers/game"
UserManager = require "./user"
Game        = require "../models/game"

games = {}

GameManager =
    io: null

    addActive: (game, callback) ->
        games[game.id] = game
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
        callback game.claimWord user, text

    canStartGame: (game, callback) ->
        if game.users.length >= game.minPlayers and not game.started

            game.start()

            @queueWord game, getRandomDelay(3000, 5000)

            return callback true

        callback false

    allSlotsClaimed: (game, callback) ->
        callback game.allSlotsClaimed()

    finishGame: (game, callback) ->
        callback false if game.finished

        game.finish()
        callback true

    queueWord: (game, delay) ->
        setTimeout =>
            numWords = 1 + Math.floor(Math.random()*3)
            words = game.spawnWords numWords
            @emitGame game, "game:word:spawn", words if words.length

            if game.isGridFull()
                # @todo make this something a bit better, obviously
                @emitGame game, "game:notification", "The grid is full!"
            else
                @queueWord game, getRandomDelay()
        , delay

    emitGame: (game, msg, data) ->
        @io.sockets.in("game:#{game.id}").emit msg, data

module.exports = GameManager

# @todo move to utils or something as getRandom(min, max)
getRandomDelay = (min = 250, max = 7000) -> min + Math.ceil(Math.random()*(max-min))
