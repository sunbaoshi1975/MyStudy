/**
 * Created by sunboss on 2014/9/3.
 */
var a = {a: 'a1', b: 'b1'};
Object.prototype.c = 'c1';

// 获取对象上的所有自有Key
console.log(Object.keys(a));

for (var i in a) {
    console.log(i + '=' + a[i]);
}

for (var i in a) {
    if (a.hasOwnProperty(i)) {
        console.log(i + '=' + a[i]);
    }
}
