function ChatController($scope, client) {
    $scope.messages = [];
    $scope.text = "";

    $scope.send = function() {
        if ($scope.text.length === 0) {
            return;
        }

        client.emit("chat:message", $scope.text);
        $scope.text = "";
    };

    $scope.format = function(dateStr) {
        var date = new Date(dateStr);
        var h = date.getHours();
        var m = date.getMinutes();
        var s = date.getSeconds();
        if (h < 10) {
            h = "0"+h;
        }
        if (m < 10) {
            m = "0"+m;
        }
        if (s < 10) {
            s = "0"+s;
        }
        return h+":"+m+":"+s;
    };

    client.on("chat:message", function(message) {
        $scope.messages.push(message);
    });

    client.on("lobby:status", function(data) {
        $scope.messages = data.messages;
    });
}
