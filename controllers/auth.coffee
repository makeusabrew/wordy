BaseController = require "./base"
UserMapper     = require "../mappers/user"

class AuthController extends BaseController
    login: (data) ->
        mapper = new UserMapper

        mapper.findByUsernameAndPass data.username, data.password, (result) =>
            return @socket.emit "auth:login:failure" if not result

            @_authUser result

    register: (data) ->
        mapper = new UserMapper

        mapper.findByUsername data.username, (result) =>
            return @socket.emit "auth:register:failure", "Username taken" if result

            # great stuff; username free. Let's register!
            mapper.create data, (result) =>
                @_authUser result

    disconnect: ->
        mapper = new UserMapper

        mapper.removeActive @socket.user.id, (result) =>
            console.log "de-authed #{@socket.user.id}"

    _authUser: (user) ->
        mapper = new UserMapper

        mapper.addActive user.id, (result) =>
            @socket.authUser user
            @socket.emit "auth:login:success", user


module.exports = AuthController
