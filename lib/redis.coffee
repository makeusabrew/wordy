redis  = require "redis"

Redis =
    client: null
    connect: ->
        @client = redis.createClient()

module.exports = Redis
