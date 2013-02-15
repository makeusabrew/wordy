function AuthController($rootScope, $scope, $location, client) {

    $rootScope.pageTitle = "Login";

    // need a private user in case of reg
    $scope.regUser  = {};

    $scope.login = function() {
        client.emit("auth:login", $rootScope.user);
    };

    $scope.register = function() {
        client.emit("auth:register", $scope.regUser);
    };

    $scope.doLogin = function() {
        $location.path("/login");
    };

    $scope.doRegister = function() {
        $location.path("/register");
    };

    client.on("auth:login:success", function(data) {
        data.password = null;
        data.authed = true;

        $rootScope.user = data;

        $location.path("/lobby");
    });

    client.on("auth:register:failure", function(data) {
        alert(data);
    });

    client.on("auth:login:failure", function() {
        alert("Invalid details");
    });
}
