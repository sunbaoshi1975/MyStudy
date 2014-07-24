/**
 * Created by sunboss on 14-6-12.
 */
var util = require('util');

function Base() {
    this.name = 'base';
    this.base = 2014;

    this.sayHello = function() {
        console.log('Hello ' + this.name);
    };
}

Base.prototype.showName = function() {
    console.log(this.name);
};

function Sub() {
    this.name = 'sub';
}

util.inherits(Sub, Base);

var objBase = new Base();
var objSub = new Sub();

objBase.showName();     // base
objBase.sayHello();     // Hello base
console.log(objBase);   // { name: 'base', base: 2014, sayHello: [Function] }

objSub.showName();      // sub
//objSub.sayHello();
console.log(objSub);    // { name: 'sub' }

