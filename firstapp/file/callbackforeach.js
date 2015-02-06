/**
 * Created by sunboss on 2014/7/24.
 */
var fs = require('fs');
var files = ['a.txt', 'b.txt', 'c.txt'];

// Notes: see also filter() and map() function, and others such as reduce(), reduceright(), lastIndexOf()
files.forEach(function(filename) {
    fs.readFile(filename, 'utf-8', function(err, contents) {
        if (err) {
            console.log(filename  + ' error: '+ err);
        } else {
            console.log(filename + ': ' + contents);
        }
    });
});