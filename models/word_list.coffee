words = ["wordy", "cat", "speciality", "quebec", "zoology", "think", "would", "their", "there", "over", "could", "good", "apparent", "back", "cite", "overlook", "redundant"]

module.exports =
    getRandomWord: ->
        index = Math.floor(Math.random()*words.length)
        return words[index]
