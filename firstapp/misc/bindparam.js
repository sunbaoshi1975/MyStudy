/**
 * Created by sunboss on 2014/8/4.
 */
var person = {
    name: 'Tony Sun',
    says: function(act, obj) {
        console.log(this.name + ' ' + act + ' ' + obj);
    }
};

person.says('loves', 'linlin');        // 输出 Tony Sun loves linlin

// Bind parameter 'act' with loves
myLoves = person.says.bind(person, 'loves');
myLoves('Emily');           // 输出 Tony Sun loves Emily
myLoves('Eric');            // 输出 Tony Sun loves Eric