angular.module("soundManager", [])
.factory("soundManager", function() {

    var sounds = {},
        context= null,
        that   = {};

    that.init = function() {
        if (typeof webkitAudioContext === 'undefined') {
            return;
        }

        context = new webkitAudioContext();
    };

    that.load = function(url, name, callback) {
        if (!context) {
            return;
        }
        // sadly we can't use $http here as AngularJS 1.0.x
        // doesn't support the responseType property

        var request = new XMLHttpRequest();
        request.open("GET", url, true);
        request.responseType = "arraybuffer";
        
        request.onload = function() {
            that.loadBuffer(request.response, name, callback);
        };

        request.send();
    };

    that.loadBuffer = function(data, name, callback) {
        context.decodeAudioData(data, function(buffer) {
            sounds[name] = buffer;

            if (callback) {
                callback();
            }
        });
    };

    that.play = function(name) {
        if (!context) {
            return;
        }

        var source = context.createBufferSource();
        source.buffer = sounds[name];
        source.connect(context.destination);
        source.noteOn(0);
    };

    return that;
});
