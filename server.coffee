express  = require "express"
sio      = require "socket.io"
cookie   = require "cookie"
connect  = require "connect"
app      = express()

Config      = require "./lib/config"
Redis       = require "./lib/redis"
EventBus    = require "./lib/event_bus"
GameManager = require "./managers/game"

sessionStore = new express.session.MemoryStore()

app.configure ->
    app.use express.static("#{__dirname}/public")
    app.use express.logger()
    app.use express.bodyParser()
    app.use express.cookieParser()
    app.use express.session({
        secret: "70c37bd941ffe3a776a320edc105b8a1",
        key: "express.sid",
        store: sessionStore
    })

    ###
    app.use (req, res, next) ->
        if req.session.user
            user = new User()
            user.populate req.session.user
            req.user = user
            res.locals.userJSON = JSON.stringify req.user
        else
            res.locals.userJSON = '{}'
            
        res.locals.user = req.user
        next()
    ###

app.configure "build", ->
    Config.load __dirname + "/config/build.json"

# start web server
server = app.listen Config.get("server", "port")

# start socket.io server
io     = sio.listen server

io.set "authorization", (data, accept) ->
    if data.headers.cookie
        data.cookie = connect.utils.parseSignedCookies(cookie.parse(decodeURIComponent(data.headers.cookie)), '70c37bd941ffe3a776a320edc105b8a1')

        data.sessionID = data.cookie['express.sid']
        data.sessionStore = sessionStore

        sessionStore.get data.sessionID, (err, session) ->
            return accept "Invalid session ID", false if err or not session

            console.log "session ID #{data.sessionID} ok"

            Session = express.session.Session
            data.session = new Session(data, session)
            accept null, true
    else
        # no cookie - for now that's no good
        accept "No cookie", true


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

###
# global event "routes"
# note that of course unlike normal route loading, these will only
# be run once and thus instantiate only one handler to deal with the
# relevant events
###
require("./events/game").load io
