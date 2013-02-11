function LobbyController($rootScope, $scope, $location, client) {

    $scope.games = [];

    $scope.join = function(game) {
        client.emit("lobby:leave");
        $location.path("/game/"+game.id);
    };

    client.on("lobby:status", function(data) {
        $scope.games = data.games;
    });

    client.on("game:spawn", function(game) {
        $scope.games.push(game);
    });

    client.emit("lobby:join");
}
