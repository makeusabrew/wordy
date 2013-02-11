angular
.module("wordy", ["client", "d3"])
.config(function($routeProvider) {

    $routeProvider.when("/lobby", {
        templateUrl: "lobby.html"
    });

    $routeProvider.when("/game/:id", {
        templateUrl: "game.html",
        controller: GameController
    });

})
.run(function($rootScope, client) {

    // want to share the authed user state
    $rootScope.user = {};

    // and the socket connection state...
    $rootScope.connected = false;

    client.connect();
});
