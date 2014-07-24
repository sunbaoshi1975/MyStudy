
/**
 * Module dependencies.
 */

var express = require('express');
var routes = require('./routes');
var user = require('./routes/user');
var http = require('http');
var path = require('path');
var partials = require('express-partials');
var util = require('util');

var settings = require('./settings');
var MongoStore = require('connect-mongo')(express);
var flash = require('connect-flash');

var sessionStore = new MongoStore({
    db : settings.db
}, function() {
    console.log('connect mongodb succeed');
});

var app = express();

// all environments
/// 在linux下
//// 只设置一次有效 $ PORT=1234 node app.js
//// 只设置永久有效  $ export PORT=1234
/// 在window下
//// 默认是永久情况
//// >set PORT=1234
//// >node app.js
app.set('port', process.env.PORT || 3000);
app.set('views', path.join(__dirname, 'views'));
app.set('view engine', 'ejs');

// 没作用
// app.set('view options', {
//    layout: false
//});
app.use(partials());
app.use(flash());
app.use(express.favicon());
app.use(express.logger('dev'));
app.use(express.json());
app.use(express.urlencoded());
app.use(express.methodOverride());

// Session
app.use(express.cookieParser());
app.use(express.session({
    secret: settings.cookieSecret,
    cookie: {
        maxAge: 60000 * 20          // 20 minutes
    },
    store: sessionStore
}));

//app.helpers({
app.locals({
    inspect:function(obj) {
        return util.inspect(obj, true);
    }
});

//app.dynamicHelpers({
//    headers: function(req, res) {
//       return req.headers;
//    }
//});

/*
app.dynamicHelper({
    user: function(req, res) {
        return req.session.user;
    },
    error: function(req, res) {
        var err = req.flash('error');
        if (err.length)
            return err;
        else
            return null;
    },
    success: function(req, res) {
        var succ = req.flash('success');
        if (succ.length)
            return succ;
        else
            return null;
    }
});
*/

app.use(function(req, res, next) {
    res.locals.headers = req.headers;
    res.locals.user = req.session.user;
    res.locals.username = req.flash('username').toString();
    res.locals.error = req.flash('error').toString();
    res.locals.success = req.flash('success').toString();
    next();
}) ;

// Replaced with express.router
//app.use(app.router);
routes(app);
//app.use(express.router(routes));
app.use(express.static(path.join(__dirname, 'public')));

// development only
if ('development' == app.get('env')) {
  app.use(express.errorHandler());
}

//--------------------------------------
// Testing
/*
var users = {
    'tonysun' : {
        name: 'Tony',
        email: 'tony.sun@smartac.co',
        address: 'Canada'
    }
};

app.all('users/:username', function(req,res, next) {
    // Verify if username exists
    if (users[req.params.username]) {
        next();
    } else {
        next(new Error(req.params.username + ' does not exist.'));
    }
});
//--------------------------------------
app.get('/', routes.index);                      // Home page
app.get('/u/:user', routes.user);              // User home
app.post('/post', routes.post);                 // Post thread
app.get('/reg', routes.reg);                    // User registration
app.post('/reg', routes.doReg);                 // Submit registration form
app.get('/login', routes.login);
app.post('/login', routes.doLogin);
app.get('/logout', routes.logout);

//-------------------------------------
// Testing
app.get('/users', user.list);
app.get('/hello', user.hello);
//app.get('/users/:username', function(req, res, next) {
//    console.log('all method captured.');
//    next();
//});
app.get('/users/:username', function(req, res) {
    // username exists for sure
    //res.send('user:' + req.params.username);
    res.send(JSON.stringify(users[req.params.username]));
});

app.get('/list', function(req, res) {
    res.render('list', {
        title: 'List',
        items: [1975, 'tony', 'express', 'Node.js']
    });
});

app.get('/help', function(req, res) {
    //res.send(app.locals.inspect(app.locals.headers));
    res.render('helper', {
        title: 'Helpers'
    });
});

// Use curl for test
/// e.g:
/// curl -X PUT -d '{"address":"waterloo"}' http://127.0.0.1:3000/users/tonysun
app.put('/users/:username', function(req, res) {
    // update user info
    res.send('Done');
});
//--------------------------------------
*/

http.createServer(app).listen(app.get('port'), function(){
  console.log('Express server listening on port ' + app.get('port'));
});
