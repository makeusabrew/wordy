express  = require "express"
sio      = require "socket.io"
cookie   = require "cookie"
connect  = require "connect"
app      = express()

Config      = require "./lib/config"
Redis       = require "./lib/redis"
EventBus    = require "./lib/event_bus"
GameManager = require "./managers/game"
WordList    = require "./models/word_list"

app.configure ->
    app.use express.static("#{__dirname}/public")
    app.use express.logger()

app.configure "build", ->
    Config.load __dirname + "/config/build.json"

app.configure "test", ->
    Config.load __dirname + "/config/test.json"

# start web server
server = app.listen Config.get("server", "port")

# start socket.io server
io     = sio.listen server

io.sockets.on "connection", require("./routes")(io)


###
# where should boot/init stuff actually go?
# it's hard to organise because the order of app / server / io
# all depend on each other
###
Redis.connect()

# cleanup. @todo move, obviously
Redis.client.del "users:active"
Redis.client.del "users:lobby"
Redis.client.del "games:active"

GameManager.io = io

WordList.loadDictWords ->
    console.log "words loaded"
