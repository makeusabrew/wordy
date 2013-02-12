activeUsers = {}
lobbyUsers = {}

UserManager =
    io: null

    addActive: (user, callback) ->

        activeUsers[user.id] = user
        callback()

    removeActive: (user, callback) ->
        delete activeUsers[user.id]
        callback()

    countAllActive: (callback) ->
        count = 0
        count += 1 for user of activeUsers

        callback count

    ###
    # a subset of active really; who's in the lobby?
    ###
    addToLobby: (user, callback) ->
        lobbyUsers[user.id] = user
        callback()

    removeFromLobby: (user, callback) ->
        delete lobbyUsers[user.id]
        callback()

    findAllLobby: (callback) ->
        flat = (user for key, user of lobbyUsers)
        callback flat

module.exports = UserManager
