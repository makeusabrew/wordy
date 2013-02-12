angular.module("client", [])
.factory("client", function($window, $rootScope) {

    var socket = null,
        user   = {},
        that   = {};

    that.connect = function() {
        socket = $window.io.connect();

        that.on("connect", function() {
            $rootScope.connected = true;
        });
    };

    that.on = function(msg, callback) {
        socket.on(msg, function() {
            var args = arguments;
            $rootScope.$apply(function() {
                callback.apply(socket, args);
            });
        });
    };

    that.emit = function(msg, data) {
        console.log(msg, data);
        socket.emit(msg, data);
    };

    return that;
});
