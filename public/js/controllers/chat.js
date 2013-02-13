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

    client.on("chat:message", function(message) {
        $scope.messages.push(message);
    });

    client.on("lobby:status", function(data) {
        $scope.messages = data.messages;
    });
}
