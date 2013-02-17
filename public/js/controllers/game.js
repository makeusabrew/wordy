function GameController($rootScope, $scope, $routeParams, $location, client, d3, soundManager) {

    $rootScope.pageTitle = "Game #"+$routeParams.id;

    $scope.game = null;
    $scope.players = [];
    $scope.messages = [];
    $scope.word = "";
    $scope.words = [];
    $scope.slots = {};

    $scope.submitWord = function() {
        client.emit("game:word", $scope.word);
        $scope.word = "";
    };

    $scope.leave = function() {
        client.emit("game:leave");
    };

    $scope.playerScore = function(p) {
        return p.score;
    };

    /**
     * init code
     */
    client.emit("game:join", $routeParams.id);

    var width = 500;
        height = 500;

    var svg = d3
    .select(".game")
    .append("svg")
    .attr("width", width+1)
    .attr("height", height+1);

    var blockSize = 50;

    for (var i = 0, j = width; i <= j; i += blockSize) {
        svg.append("line")
        .attr("x1", i+0.5)
        .attr("x2", i+0.5)
        .attr("y1", 0)
        .attr("y2", height)
        .attr("stroke", "grey");
    }

    for (var i = 0, j = height; i <= j; i += blockSize) {
        svg.append("line")
        .attr("x1", 0)
        .attr("x2", width)
        .attr("y1", i+0.5)
        .attr("y2", i+0.5)
        .attr("stroke", "grey");
    }

    var blocks = width/blockSize;

    /**
     * handlers
     */
    client.on("game:word:spawn", function(data) {

        soundManager.play("spawn");

        data.forEach(function(word) {

            $scope.slots.available -= word.size;

            $scope.words.push(word);

            var x = word.x * blockSize;
            var y = word.y * blockSize;


            var blockWidth = blockSize*word.size;
            var r = {
                angle: word.rotation*90,
                x: blockSize / 2,
                y: blockSize / 2
            };

            var block = svg.append("g")
            .attr("data-id", word.id)
            .attr("data-angle", r.angle)
            .attr("data-x", x)
            .attr("data-y", y)
            .attr("transform", "translate("+x+", "+y+") rotate("+r.angle+", "+r.x+", "+r.y+")")
            .attr("opacity", 0);

            block
            .append("rect")
            .attr("data-size", word.size)
            .attr("width", blockSize*word.size)
            .attr("height", blockSize);
            
            block
            .append("text")
            .attr("class", "word")
            .attr("text-anchor", "middle")
            .attr("x", blockWidth/2)
            .attr("y", 26)
            .attr("fill", "white")
            .text(word.text);

            block
            .transition()
            .duration(500)
            .attr("opacity", "1");
        });
    });

    client.on("game:status", function(data) {
        $scope.game = data;
        $scope.players = data.users;

        $scope.slots.total = $scope.slots.available = data.width * data.height;
    });

    client.on("game:user:join", function(data) {
        $scope.players.push(data);
    });

    client.on("game:word:claim", function(data) {

        if (data.userId === $rootScope.user.id) {
            soundManager.play("claim");
        }

        var block = svg.select("g[data-id='"+data.wordId+"']");

        var player = getPlayer(data.userId);
        var word = getWord(data.wordId);

        var rect = block.select("rect");
        var xOff = 0,
            yOff = 0;

        switch (+block.attr("data-angle")) {
            case 0:
                xOff = blockSize;
                break;
            case 90:
                yOff = blockSize;
                break;
            case 180:
                xOff = -blockSize;
                break;
            case 270:
                yOff = -blockSize;
                break;
        }

        for (var i = 0, j = rect.attr("data-size"); i < j; i++) {
            // we want to append straight to SVG otherwise we'll
            // have to undo all the rotation already applied on
            // the group
            // however, having to work out all the offsets and
            // stuff extra data against the block is not ideal...
            svg.append("image")
            .attr("xlink:href", $rootScope.getAvatar(player))
            .attr("x", +block.attr("data-x")+(xOff*i))
            .attr("y", +block.attr("data-y")+(yOff*i))
            .attr("width", blockSize)
            .attr("height", blockSize)
            .attr("opacity", 0)
            .transition()
            .attr("opacity", 0.7);
        }

        player.score = data.currentScore;

        var msg = {
            user: player,
            word: word,
            points: data.points,
            combo: data.combo
        };

        $scope.messages.push(msg);
    });

    client.on("game:notification", function(data) {
        // ???
        console.log(data);
    });

    client.on("game:results", function(game) {
        // for now just update the game object
        $scope.game = game;
    });

    client.on("game:countdown", function(value) {
        var block = svg.append("g")
        .attr("transform", "translate("+width/2+", "+height/2+")");

        block
        .append("text")
        .attr("class", "word--countdown")
        .attr("opacity", 0)
        .attr("text-anchor", "middle")
        .attr("dy", "60px")
        .text(value)
        .transition(100)
        .attr("opacity", 1)
        .transition(100)
        .delay(800)
        .attr("transform", "scale(0)")
        .remove();
    });

    client.on("game:leave", function() {
        $location.path("/lobby");
    });

    function getObjectById(id, property) {
        var i = $scope[property].length;
        while (i--) {
            var object = $scope[property][i];
            if (object.id == id) {
                return object;
            }
        }
    }

    function getPlayer(id) {
        return getObjectById(id, 'players');
    }

    function getWord(id) {
        return getObjectById(id, 'words');
    }
}
