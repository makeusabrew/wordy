assert = require "./lib/assert"

Game = require "../models/game"

# dummy but useful data
object =
    id: 123
    minPlayers: 1
    maxPlayers: 2
    started: "started"
    finished: "finished"
    created: "created"
    width: 10
    height: 10

describe "Game model", ->
    game = null

    describe "when instantiated with no arguments", ->
        before -> game = new Game

        it "should have none of its basic properties set", ->
            assert.equal null, game.id
            assert.equal null, game.minPlayers
            assert.equal null, game.maxPlayers
            assert.equal null, game.started
            assert.equal null, game.finished
            assert.equal null, game.created
            assert.equal null, game.width
            assert.equal null, game.height

        it "should have the correct starting word ID", ->
            assert.equal 1, game.wordId

        it "should have an empty words array", ->
            assert.equal 0, game.words.length

        it "should have no slots taken", ->
            assert.equal 0, game.slotsTaken

        it "should have no slots claimed", ->
            assert.equal 0, game.slotsClaimed

        it "should have no users", ->
            assert.equal 0, game.users.length

    describe "when instantiated with an object argument", ->
        before ->
            game = new Game object

        it "should have all of its basic properties set", ->
            assert.equal 123, game.id
            assert.equal 1, game.minPlayers
            assert.equal 2, game.maxPlayers
            assert.equal "started", game.started
            assert.equal "finished", game.finished
            assert.equal "created", game.created
            assert.equal 10, game.width
            assert.equal 10, game.height

    describe "#unclaimedTileCount", ->
        before ->
            game = new Game object

        describe "with a new object", ->

            it "should return zero", ->
                assert.equal 0, game.unclaimedTileCount()

        describe "when spawning a word spanning one tile", ->
            before ->
                slot = game.gridList[0]
                game.spawnWordAtSlot "foo", slot

            it "should return one", ->
                assert.equal 1, game.unclaimedTileCount()

        describe "when spawning another word spanning two tiles", ->
            before ->
                slot = game.gridList[1]
                game.spawnWordAtSlot "foobar", slot

            it "should return three", ->
                assert.equal 3, game.unclaimedTileCount()

        describe "when claiming the first word", ->
            before ->
                user =
                    id: 123
                game.claimWord user, "foo"

            it "should return two", ->
                assert.equal 2, game.unclaimedTileCount()

    ###
    describe "#start", ->
        before ->
            game = new Game object
            game.start()
    ###
