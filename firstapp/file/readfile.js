/**
 * Created by sunboss on 14-7-1.
 */
var fs = require('fs');

fs.readFile('readme.txt', 'utf-8', function(err, data) {
    if (err) {
        console.log(err);
    } else {
        console.log(data);
    }
});