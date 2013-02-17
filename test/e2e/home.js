var casper = require("casper").create({
    /*
    verbose: true,
    logLevel: "debug"
    */
});

casper.start("http://localhost:8765");

casper.then(function() {
    this.test.assertTitle("Wordy - Login");
});

/*
casper.then(function() {
    this.fill("form:eq(0)", {
        //
    });
});
*/

casper.run();
