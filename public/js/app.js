angular
.module("wordy", ["client", "d3"])
.config(function($routeProvider) {

    $routeProvider.when("/lobby", {
        templateUrl: "lobby.html"
    });

    $routeProvider.when("/login", {
        templateUrl: "login.html",
        controller: AuthController
    });

    $routeProvider.when("/register", {
        templateUrl: "register.html",
        controller: AuthController
    });

    $routeProvider.when("/game/:id", {
        templateUrl: "game.html",
        controller: GameController
    });

})
.run(function($rootScope, $location, client) {

    // want to share the authed user state
    $rootScope.user = {};
    // and whether the client is connected or not
    $rootScope.connected = false;

    client.connect(function() {
        $rootScope.connected = true;
        $location.path("/login");

    });
});
