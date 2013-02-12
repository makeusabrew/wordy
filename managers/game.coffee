GameMapper = require "../mappers/game"
Game       = require "../models/game_runner"
UserManager= require "./user"

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
        flat = (game for game of games)
        callback flat

    addUserToGame: (user, game, callback) ->
        if not game.users
            game.users = []

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

                games = new GameMapper

                games.create data, (game) =>
                    @addActive new Game(@io, game), =>
                        callback game

    findGame: (id, callback) ->
        return callback null if not games[id]

        callback games[id]

    claimWord: (id, userId, word, callback) ->
        @findGame id, (game) =>
            return callback null if game is null

            game.findWord word, (word, index) =>
                game.claimWord userId, index, callback if word

    canStartGame: (game, callback) ->
        if game.users.length >= game.minPlayers and not game.started

            game.start()
            return callback true

        callback false



module.exports = GameManager
