fs = require "fs"

words = []

module.exports =
    getRandomWord: ->
        index = Math.floor(Math.random()*words.length)
        return words[index]

    loadDictWords: (callback) ->
        stream = fs.createReadStream "/usr/share/dict/words"

        words = []
        stream.on "data", (data) =>
            data = data.toString "utf8"

            for word in data.split("\n")
                if word.search(/'s$/) is -1 and
                        word.search(/[éåö]/) is -1 and
                        word.length > 2 and
                        word.toUpperCase() isnt word

                    words.push word.toLowerCase()

        stream.on "end", =>
            callback true
