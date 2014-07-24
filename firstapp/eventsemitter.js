/**
 * Created by sunboss on 14-7-1.
 * Add, emit and remove event
 */
var events = require('events');
var emitter = new events.EventEmitter();

emitter.on('someEvent', function(data1, data2) {
    console.log('listener1', data1, data2);
});

var callback = function(data1, data2) {
    console.log('listener2', data1, data2);
};
emitter.on('someEvent', callback);

emitter.once('someEvent', function(data1, data2) {
   console.log('listener once', data1, data2);
});

emitter.emit('someEvent', 'It works!', 2014);
emitter.emit('someEvent', 'It works again', 2014);

emitter.removeListener('someEvent', callback);

emitter.emit('someEvent', 'It works third time', 2014);