RedisMapper = require "./base"
EventBus    = require "../lib/event_bus"
bcrypt      = require "bcrypt"

class UserMapper extends RedisMapper
    prefix: "user"

    findByUsernameAndPass: (username, pass, callback) ->
        @findByUsername username, (result) ->
            return callback null if result is null

            if bcrypt.compareSync pass, result.password
                callback result
            else
                callback null

    findByUsername: (username, callback) ->
        # first of all check if this username exists at all
        @client.get "username:#{username}:id", (err, id) =>
            return callback null if id is null

            @find id, callback

    create: (data, callback) ->
        @client.incr "global:userId", (err, id) =>
            @client.set "username:#{data.username}:id", id, (err, result) =>
                salt = bcrypt.genSaltSync 10
                hash = bcrypt.hashSync data.password, salt

                # augment the incoming data 
                object =
                    id: id
                    password: hash
                    username: data.username

                @client.set "user:#{id}:object", JSON.stringify(object), (err, result) =>
                    callback object

    findAllLobby: (callback) ->
        @client.smembers "users:lobby", (err, results) =>
            queries = []
            queries.push "user:#{id}:object" for id in results

            @client.mget queries, (err, results) =>

                callback @toCollection results

    ###
    # simply keep track of *all* active users (logged in)
    ###
    addActive: (id, callback) ->
        @client.sadd "users:active", id, (err, result) ->
            # @todo move behind client class...
            EventBus.emit "redis:users:active:sadd"
            callback result

    removeActive: (id, callback) ->
        @client.srem "users:active", id, (err, result) ->
            # @todo move behind client class...
            EventBus.emit "redis:users:active:srem"
            callback result

    countAllActive: (callback) ->
        @client.scard "users:active", (err, count) =>
            callback count

    ###
    # a subset of active really; who's in the lobby?
    ###
    addToLobby: (id, callback) ->
        @client.sadd "users:lobby", id, (err, result) ->
            callback result

    removeFromLobby: (id, callback) ->
        @client.srem "users:lobby", id, (err, result) ->
            callback result


module.exports = UserMapper
