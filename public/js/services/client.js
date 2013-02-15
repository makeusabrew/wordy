angular.module("client", [])
.factory("client", function($window, $rootScope) {

    var socket = null,
        user   = {},
        that   = {};

    that.connect = function(callback) {
        socket = $window.io.connect();

        that.on("connect", function() {
            callback();
        });
    };

    that.on = function(msg, callback) {
        socket.on(msg, function() {
            var args = arguments;
            console.log("←", msg, args);
            $rootScope.$apply(function() {
                callback.apply(socket, args);
            });
        });
    };

    that.emit = function(msg, data) {
        console.log("→", msg, data);
        socket.emit(msg, data);
    };

    that.removeListeners = function() {
        socket.removeAllListeners();
    };

    return that;
});
