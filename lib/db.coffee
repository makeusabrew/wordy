mysql  = require "mysql"
Config = require "./config"

Db =
    connection: null
    connect: ->
        @connection = mysql.createConnection({
            host     : Config.get("db", "host"),
            user     : Config.get("db", "user"),
            password : Config.get("db", "pass"),
            database : Config.get("db", "name")
        })

        @connection.connect()

module.exports = Db
