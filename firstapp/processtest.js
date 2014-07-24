// print program argv and methods belong to process
var util = require('util');
console.log(process.argv);
console.log('Platform=' + process.platform);
console.log('PID=%d', process.pid);
console.log('Exe Path=%s', process.execPath);
console.log('Memory Usgae: ' + util.inspect(process.memoryUsage(), true));

/*
//stdin & out
process.stdin.resume();

process.stdin.on('data', function(data) {
    process.stdout.write('read from console: ' + data.toString());
});
*/

/*
// Demo for NextTick
var myModule = require('./module');
function doSomething(args,callback) {
    myModule.compute1();
    callback();
    //process.nextTick(callback);
};

doSomething("aaa", function onEnd() {
    myModule.compute2();
});
*/