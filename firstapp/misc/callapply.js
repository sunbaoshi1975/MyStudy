/**
 * Created by sunboss on 2014/8/4.
 */
var someuser = {
    name: 'Tony Sun',
    display: function(words) {
        console.log(this.name + ' says ' + words);
    }
};

var foo = {
    name: 'foobar'
};

someuser.display.call(foo, 'hello');        // 输出 foobar says hello