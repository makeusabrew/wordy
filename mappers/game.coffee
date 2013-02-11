RedisMapper = require "./base"
UserMapper = require "./user"

class GameMapper extends RedisMapper
    prefix: "game"

    findAllActive: (callback) ->
        @client.smembers "games:active", (err, results) =>
            return callback [] if not results.length

            queries = []
            queries.push "game:#{id}:object" for id in results

            @client.mget queries, (err, results) =>

                callback @toCollection(results)

    countAllActive: (callback) ->
        @client.scard "games:active", (err, count) =>
            callback count

    addActive: (id, callback) ->
        @client.sadd "games:active", id, (err, result) ->
            callback result

    addUserToGame: (userId, gameId, callback) ->
        @client.sadd "game:#{gameId}:users", userId, (err, result) ->
            callback result

    findUsers: (id, callback) ->
        @client.smembers "game:#{id}:users", (err, results) =>
            return callback [] if not results.length

            (new UserMapper).findMulti results, callback

    # full game details; game itself, users, scores
    getGameState: (gameId, callback) ->
        @find gameId, (game) =>
            @findUsers gameId, (users) =>

                data =
                    game: game
                    users: users

                callback data

module.exports = GameMapper
