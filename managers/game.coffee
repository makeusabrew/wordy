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

        game.users.push user

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
        # note: we give findWord text, we get an object back
        # not sure we really need two methods here... why can't
        # claimWord just take a text input and be done with it?
        game.findWord text, (word, index) =>
            return game.claimWord user.id, index, callback if word

            callback null

    canStartGame: (game, callback) ->
        if game.users.length >= game.minPlayers and not game.started

            game.start()
            return callback true

        callback false

    allSlotsClaimed: (game, callback) ->
        callback game.allSlotsClaimed()

    finishGame: (game, callback) ->
        callback false if game.finished

        game.finish()
        callback true

module.exports = GameManager
