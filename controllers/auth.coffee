BaseController = require "./base"
UserMapper     = require "../mappers/user"
UserManager    = require "../managers/user"

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
        UserManager.removeActive @socket.user, =>
            # we need to emit a pretty global message here since
            # it affects clients in all states
            @socket.emitAll "user:disconnect", @socket.user

    _authUser: (user) ->
        UserManager.addActive user, =>
            @socket.authUser user
            @socket.emit "auth:login:success", user


module.exports = AuthController
