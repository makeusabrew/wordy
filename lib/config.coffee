fs = require "fs"

data = {}
Config =
    load: (path) ->
        raw = fs.readFileSync path
        data = JSON.parse raw

    get: (key, sub = null) ->
        return data[key]?[sub] if sub

        return data[key]

module.exports = Config
