RedisMapper = require "./base"
UserMapper = require "./user"

class GameMapper extends RedisMapper
    prefix: "game"

module.exports = GameMapper
