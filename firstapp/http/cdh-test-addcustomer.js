/**
 * Created by sunboss on 14-7-14.
 * working with Cloud Data Hub prototype by Stephen Wang
 */
var http = require('http');
//var querystring = require('querystring');

var contents = {
    'username': 'Tony Sun',
    'email': 'tony.sun@smartac.co',
    'number':'13916319585',
    'mac': '848F69B8A327'
};
contents = JSON.stringify(contents);
console.log(contents);

var option = {
    host: '172.16.0.34',
    port: 5000,
    path: '/customer/1/u10010',
    method: 'POST',
    headers: {
        'Content-Type': 'application/json',
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