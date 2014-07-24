//module.js - function export
// work with gethello.js
var name;

exports.setName = function(thyName) {
    name = thyName;
};

exports.sayHello = function() {
    console.log('Hello ' + name);
};

exports.sleep = function(numberMillis) {
    var now = new Date();
    var exitTime = now.getTime() + numberMillis;

    while (true) {
        now = new Date();
        if (now.getTime() > exitTime)
            return;
    }
};

exports.compute1 = function() {
    console.log('compute 1 started.');

    var p = 1;
    for(var i = 1; i<3000000; i++) {
        //this.sleep(20);
        p*=5;
        p<<=1;
        p*=2;
    }
    console.log('compute 1 finished.');
};

exports.compute2 = function() {
    console.log('compute 2 started.');
    var p = 1;
    for(var i = 1; i<3000000; i++) {
        p*=5;
        p<<=1;
        p*=2;
    }
    console.log('compute 2 finished.');
};