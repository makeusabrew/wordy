function GameController($scope, $routeParams, client, d3) {

    $scope.game = null;
    $scope.players = [];
    $scope.messages = [];
    // user's text input
    $scope.word = "";
    // active game words
    $scope.words = [];

    $scope.submitWord = function() {
        client.emit("game:word", $scope.word);
        $scope.word = "";
    };

    /**
     * init code
     */
    client.emit("game:join", $routeParams.id);

    var width = 500;
        height = 500;

    var svg = d3
    .select(".game-svg")
    .append("svg")
    .attr("width", width)
    .attr("height", height);

    var blockSize = 50;

    for (var i = blockSize+.5, j = width; i < j; i += blockSize) {
        svg.append("line")
        .attr("x1", i)
        .attr("x2", i)
        .attr("y1", 0)
        .attr("y2", height)
        .attr("stroke", "grey");
    }

    for (var i = blockSize+.5, j = height; i < j; i += blockSize) {
        svg.append("line")
        .attr("x1", 0)
        .attr("x2", width)
        .attr("y1", i)
        .attr("y2", i)
        .attr("stroke", "grey");
    }

    var blocks = width/blockSize;

    /**
     * handlers
     */
    client.on("game:word:spawn", function(data) {
        data.forEach(function(word) {
            var x = word.x * blockSize;
            var y = word.y * blockSize;

            var block = svg.append("g")
            .attr("data-id", word.id)
            .attr("transform", "translate("+x+", "+y+")")
            .attr("opacity", 0);

            block
            .append("rect")
            .attr("width", blockSize)
            .attr("height", blockSize);
            
            block
            .append("text")
            .attr("class", "word")
            .attr("text-anchor", "middle")
            .attr("x", 25)
            .attr("y", 25)
            .attr("fill", "white")
            .text(word.text);

            block.transition().attr("opacity", "1");
        });
    });

    client.on("game:status", function(data) {
        $scope.game = data.game;
    });

    client.on("game:user:join", function(data) {
        $scope.users.push(data);
    });

    client.on("game:message", function(message) {
        $scope.messages.push(message);
    });

    client.on("game:word:claim", function(data) {
        var block = svg.select("g[data-id='"+data.wordId+"']");

        block.select("rect")
        .attr("fill", "red");

        $scope.messages.push("Player ["+data.userId+"] claimed word ["+data.wordId+"] for score ["+data.score+"]");
    });
}
