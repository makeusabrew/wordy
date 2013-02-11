function GameController($scope, $routeParams, client, d3) {

    $scope.game = null;
    $scope.players = [];

    client.on("game:status", function(data) {
        $scope.game = data.game;
    });

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

    client.on("game:word:spawn", function(data) {
        data.forEach(function(word) {
            var x = word.x * blockSize;
            var y = word.y * blockSize;

            var block = svg.append("g")
            .attr("transform", "translate("+x+", "+y+")")
            .attr("opacity", 0);

            block
            .append("rect")
            .attr("width", blockSize)
            .attr("height", blockSize);
            
            block
            .append("text")
            .attr("text-anchor", "middle")
            .attr("x", 25)
            .attr("y", 25)
            .attr("fill", "white")
            .text(word.text);

            block.transition().attr("opacity", "1");
        });
    });
}
