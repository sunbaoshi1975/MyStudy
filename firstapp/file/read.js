/**
 * Created by sunboss on 14-7-1.
 */
var fs = require('fs');
var strFileName = 'readme.txt';

fs.open(strFileName, 'r', function(err, fd) {
    if (err) {
        console.log(err);
        return;
    } else {
        console.log('File: %s opened OK!', strFileName);
    }

    var buf = new Buffer(100);

    var callback = function(err, bytRead, buffer) {
        if (err) {
            console.log(err);
            return;
        } else {
            console.log('Read %d bytes', bytRead);
            console.log(buffer.toString());

            if (bytRead < 100) {
                console.log('Finish reading!');
                fs.close(fd, function(err) {
                   if (err) {
                       console.log(err);
                   } else {
                       console.log('File: %s is closed!', strFileName);
                   }
                });
            } else {
                fs.read(fd, buf, 0, 100, null,callback);
            }
        }
    };

    fs.read(fd, buf, 0, 100, null,callback);
});
