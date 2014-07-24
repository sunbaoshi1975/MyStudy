/**
 * Created by sunboss on 14-7-14.
 * working with Cloud Data Hub prototype by Stephen Wang
 */
var http = require('http');
//var querystring = require('querystring');

var contents = {
    'area': 'food',
    'position': '100,150',
    'type': 'Apple 5S',
    'number':'13916319585'
};
contents = JSON.stringify(contents);
console.log(contents);

var option = {
    host: '172.16.0.34',
    port: 5000,
    path: '/device/1/848F69B8A327',
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