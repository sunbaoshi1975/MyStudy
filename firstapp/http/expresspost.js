/**
 * Created by sunboss on 14-7-2.
 */
var express = require('express');

//var app = express.createServer();
var app = express();
app.use(express.bodyParser());
app.all('/user', function(req, res) {
    res.send(req.body.name + req.body.email);
});

app.listen(3000);