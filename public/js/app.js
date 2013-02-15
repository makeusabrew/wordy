angular
.module("wordy", ["client", "d3"])
.config(function($routeProvider, $locationProvider) {

    $locationProvider.html5Mode(true);

    $routeProvider.when("/lobby", {
        templateUrl: "/lobby.html",
        controller: LobbyController
    });

    $routeProvider.when("/login", {
        templateUrl: "/login.html",
        controller: AuthController
    });

    $routeProvider.when("/register", {
        templateUrl: "/register.html",
        controller: AuthController
    });

    $routeProvider.when("/game/:id", {
        templateUrl: "/game.html",
        controller: GameController
    });

})
.run(function($rootScope, $location, client) {

    // want to share the authed user state
    $rootScope.user = {};
    // and whether the client is connected or not
    $rootScope.connected = false;

    // @todo don't like this much, but we need to access it from all
    // our views - would a service let us do that??
    $rootScope.getAvatar = function(user) {
        return "http://www.gravatar.com/avatar/"+user.emailHash+"?d=retro";
    };

    client.connect(function() {
        $rootScope.connected = true;
        $location.path("/login");

    });
});
