redis = require "../lib/redis"

class RedisMapper
    prefix: ""
    constructor: ->
        @client = redis.client

    toObject: (data) ->
        return {} if data is null

        JSON.parse data

    toCollection: (data) ->
        final = []
        final.push @toObject(line) for line in data
        return final

    find: (id, callback) ->
        @client.get "#{@prefix}:#{id}:object", (err, result) =>
            return callback null if result is null

            callback @toObject result

    findMulti: (ids, callback) ->
            queries = []
            queries.push "#{@prefix}:#{id}:object" for id in ids

            @client.mget queries, (err, results) =>

                callback @toCollection(results)

    update: (id, data, callback) ->
        @client.set "#{@prefix}:#{id}:object", JSON.stringify(data), (err, result) ->
            return callback null if result is null

            callback data

    create: (data, callback) ->
        @client.incr "global:#{@prefix}Id", (err, id) =>
            # augment
            data.id = id

            @update id, data, callback



module.exports = RedisMapper
