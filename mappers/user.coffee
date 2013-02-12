RedisMapper = require "./base"
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

module.exports = UserMapper
