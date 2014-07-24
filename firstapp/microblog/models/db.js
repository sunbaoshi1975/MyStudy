/**
 * Created by sunboss on 14-7-11.
 * Database Objects
 */
var settings = require('../settings');
var Db = require('mongodb').Db;
var Connection = require('mongodb').Connection;
var Server = require('mongodb').Server;
//var MongoStore = require('connect-mongo');

module.exports = new Db(settings.db, new Server(settings.host, Connection.DEFAULT_PORT, {}));
