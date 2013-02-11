GameMapper = require "../mappers/game"
UserMapper = require "../mappers/user"

GameRunner = require "../models/game_runner"

games = {}

GameManager =
    io: null

    checkSpawnNewGame: (callback) ->
        users = new UserMapper
        games = new GameMapper

        users.countAllActive (numUsers) =>
            games.countAllActive (numGames) =>
                # @todo do some clever stuff on users Vs games, for now just spawn
                data =
                    created: new Date
                    started: null
                    finished: null
                    minPlayers: 1
                    maxPlayers: 8
                    width: 10
                    height: 10

                games.create data, (game) =>
                    games.addActive game.id, =>

                        games[game.id] = new GameRunner @io, game

                        callback game

    startGame: (id, callback) ->
        @findGame id, (game) =>
            return callback null if game is null

            game.start()

            callback true

    findGame: (id, callback) ->
        return callback null if not games[id]

        callback games[id]

module.exports = GameManager
