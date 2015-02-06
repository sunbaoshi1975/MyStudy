//hello.js - base class

function Hello() {  // 构造函数
    var name;

    this.setName = function(thyName) {
        name = thyName;
    };

    this.sayHello = function() {
        console.log('Hello ' + name);
    };
};

module.exports = Hello;