/**
 * Created by sunboss on 14-6-12.
 */
var util = require('util');

function Person() {
    this.name = 'Tony Sun';
    this.toString = function() {
        return this.name;
    }
}

var obj = new Person();

console.log(util.inspect(obj));
console.log(util.inspect(obj, true));
