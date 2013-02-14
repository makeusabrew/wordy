fs = require "fs"

words = {}

module.exports =

    getWordUpToLength: (max) ->
        pool = []
        pool = pool.concat list for len, list of words when len <= max

        index = Math.floor(Math.random()*pool.length)
        return pool[index]

    loadDictWords: (callback) ->
        stream = fs.createReadStream "/usr/share/dict/words"

        words = {}
        stream.on "data", (data) =>
            data = data.toString "utf8"

            for word in data.split("\n")
                if word.search(/'s$/) is -1 and
                        word.search(/[éåö]/) is -1 and
                        word.length > 2 and
                        word.toUpperCase() isnt word

                    len = word.length

                    words[len] = [] if not words[len]
                    words[len].push word.toLowerCase()

        stream.on "end", =>
            callback true
