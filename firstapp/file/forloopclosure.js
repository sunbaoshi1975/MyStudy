/**
 * Created by sunboss on 2014/7/24.
 * 匿名函数：由于运行时闭包的存在，该匿名函数中定义的变量（包括参数表）在它内部的函
 * 数（ fs.readFile 的回调函数）执行完毕之前都不会释放
 */
var fs = require('fs');
var files = ['a.txt', 'b.txt', 'c.txt'];

for (var i=0; i<files.length; i++) {
    (function(i) {
        fs.readFile(files[i], 'utf-8', function(err, contents) {
            if (err) {
                console.log(files[i]  + ' error: '+ err);
            } else {
                console.log(files[i] + ': ' + contents);
            }
        });
    })(i);
}