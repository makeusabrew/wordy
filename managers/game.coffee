EventBus   = require "../lib/event_bus"
GameMapper = require "../mappers/game"
UserMapper = require "../mappers/user"

class GameManager
    constructor: (@io) ->

    onAddActiveUser: ->
        # we could of course alternatively just set up a loop to
        # periodically check the number of users instead
        users = new UserMapper
        games = new GameMapper

        users.countAllActive (numUsers) =>
            games.countAllActive (numGames) =>
                @checkSpawnNewGame numUsers, numGames

    onRemoveActiveUser: ->
        users = new UserMapper

        users.countAllActive (numUsers) =>
            console.log numUsers

    checkSpawnNewGame: (users, games) ->
        # @todo do some clever stuff on users Vs games, for now just spawn
        # add new game to redis
        # add new game to games:active
        # @io.broadcast "new game, come and get it!"
        data =
            created: new Date
            started: null
            finished: null

        mapper = new GameMapper
        mapper.create data, (game) =>
            mapper.addActive game.id, =>
                @io.sockets.emit "game:spawn", game

module.exports = GameManager
