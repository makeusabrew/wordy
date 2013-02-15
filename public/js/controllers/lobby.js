function LobbyController($rootScope, $scope, $location, client) {

    $scope.games = [];
    $scope.users = [];

    $scope.join = function(game) {
        client.emit("lobby:leave");
        $location.path("/game/"+game.id);
    };

    client.on("lobby:status", function(data) {
        $scope.games = data.games;
        $scope.users = data.users;
    });

    client.on("game:spawn", function(game) {
        $scope.games.push(game);
    });

    client.on("lobby:user:join", function(user) {
        $scope.users.push(user);
    });

    client.on("lobby:user:leave", userLeave);
    client.on("user:disconnect", userLeave);

    // @todo need to listen out for updates to games too:
    // started, finished, player joined, player left etc
    /*
    client.on("game:status:notify", function(game) {
        // ???
    });
    */

    client.emit("lobby:join");

    function userLeave(user) {
        var i = $scope.users.length;
        while (i--) {
            var u = $scope.users[i];
            if (u.id === user.id) {
                return $scope.users.splice(i, 1);
            }
        }
    }
}
