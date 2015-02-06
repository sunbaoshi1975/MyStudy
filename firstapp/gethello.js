//gethello.js

//--------------------------------------
// Package
var myPack = require('./mypackage');
var myPack2 = require('./mypackage');

myPack.hello('Tony SBS @Package');          // // Hello Tony SBS @Package
myPack2.hello('Tony SBS @Package2');        // Hello Tony SBS @Package2

//--------------------------------------
// Class
var Hello = require('./hello');

hello = new Hello();
hello.setName('Tony SBS @Class');
hello.sayHello();               // Hello Tony SBS @Class

hello2 = new Hello();
hello2.setName('Tony SBS @Class2');
hello2.sayHello();              // Hello Tony SBS @Class2
hello.sayHello();               // Hello Tony SBS @Class

//--------------------------------------
// Module
var myModule = require('./module');
myModule.setName('Tony SBS @Module');
myModule.sayHello();            // Hello Tony SBS @Module

var myModule2 = require('./module');
myModule2.setName('Tony SBS @Module2');
myModule2.sayHello();           // Hello Tony SBS @Module2
myModule.sayHello();            // Hello Tony SBS @Module2
