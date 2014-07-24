/**
 * Created by sunboss on 14-7-2.
 *  working with httpserverpost.js or httpserverpost2.js
 */
var http = require('http');
var querystring = require('querystring');

var contents = querystring.stringify({
    name: 'Tony Sun',
    email: 'tony.sun@smartac.co',
    address: '3F, 288 Dongping Street, SIP, Suzhou'
});

var option = {
    host: '127.0.0.1',
    port: 3000,
    path: '/user',
    method: 'POST',
    headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Content-Length': contents.length
    }
};

var req = http.request(option, function(res) {
    res.setEncoding('utf8');
    res.on('data', function(data) {
        console.log(data);
    });
});

req.write(contents);
req.end();