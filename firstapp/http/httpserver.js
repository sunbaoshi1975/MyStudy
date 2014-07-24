/**
 * Created by sunboss on 14-7-1.
 */
var http = require('http');
var nPort = 3000;

var server = new http.Server();
server.on('request', function(req, res) {
    res.writeHead(200, {'Content-Type': 'text/html'});
    res.write('<h1>Node.js</h1>');
    res.end('<p>Hello World</p>');
});
server.listen(nPort);
console.log('HTTP server is listening at port %d', nPort);