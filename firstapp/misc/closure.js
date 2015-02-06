/**
 * Created by sunboss on 2014/8/3.
 */
var generateClosure = function() {
    var count = 0;
    var get = function() {
        count++;
        return count;
    }
    return get;         // return function
};

var counter1 = generateClosure();
var counter2 = generateClosure();
console.log(counter1());        // output: 1
console.log(counter2());        // output: 1
console.log(counter1());        // output: 2
console.log(counter1());        // output: 3
console.log(counter2());        // output: 2