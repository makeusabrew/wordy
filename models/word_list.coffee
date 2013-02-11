words = ["wordy", "cat", "speciality", "quebec", "zoology"]

module.exports =
    getRandomWord: ->
        index = Math.floor(Math.random()*words.length)
        return words[index]
