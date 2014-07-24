/**
 * Created by sunboss on 14-7-2.
 */
var http = require('http');
var req = http.get({host:'www.smartac.co'});

req.on('response', function(res) {
    res.setEncoding('utf8');
    res.on('data', function(data) {
        console.log(data);
    });
});
