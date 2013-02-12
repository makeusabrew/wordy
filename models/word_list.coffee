words = [
    "wordy", "cat", "speciality", "quebec", "zoology", "think", "would", "their",
    "there", "over", "could", "good", "apparent", "back", "cite", "overlook", "redundant",
    "ever", "multiple", "spawn", "once", "infinite", "music", "transform", "neanderthal",
    "excitable", "exit", "elephant", "yacht", "study", "video", "willing", "species"]

module.exports =
    getRandomWord: ->
        index = Math.floor(Math.random()*words.length)
        return words[index]
