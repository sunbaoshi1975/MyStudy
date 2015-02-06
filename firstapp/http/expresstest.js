/**
 * Created by sunboss on 2014/8/5.
 */
var app = require('express').createServer();        // old grammar
//var express = require('express');
//var app = express();

var port = 1337;
app.listen(port);
app.get('/', function(req, res) {
    res.send('hello world');
});
console.log('start express server on port %d', port);