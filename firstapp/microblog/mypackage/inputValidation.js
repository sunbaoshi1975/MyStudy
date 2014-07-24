/**
 * Created by sunboss on 2014/7/23.
 * General validation to user input, apply async mode when finished validation do callback
 * including:
 *      username
 *      password
 *      ...
 */

// 验证用户名
// 规则：
/// 1. 非空
/// 2. 长度[3-20]
/// 3. 字符集包括字母、数字、下划线，
/// 4. 字母开头
/// 正则：^[a-zA-Z][a-zA-Z0-9|_]{2,19}$
/// 返回值：
/// err = null, 正确
/// errIsNull: 空串
/// errTooShort: 太短
/// errTooLong: 太长
/// errInvalidChar: 非法字符
/// errInvalidStart: 非字母开头
exports.testUsername = function(strUsername, callback) {
    var errCode = null;
    //var str = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_0123456789';
    var regExp = /^[a-zA-Z][a-zA-Z0-9|_]{2,19}$/;

    if (strUsername.length == 0) {
        // 用户名不能为空
        errCode = 'errIsNull';
    } else if (strUsername.length < 3) {
        // 长度：过短
        errCode = 'errTooShort';
    } else if (strUsername.length > 20) {
        // 长度：过长
        errCode = 'errTooLong';
    } else if (!((strUsername[0] >= 'a' && strUsername[0] <= 'z') || (strUsername[0] >= 'A' && strUsername[0] <= 'Z'))) {
        // 长度：非字母开头
        errCode = 'errInvalidStart';
    } else if (!regExp.test(strUsername)) {
        // 长度：非法字符，使用正则表达式匹配
        errCode = 'errInvalidChar';
    }

    return callback(errCode);
};

// 验证口令
// 规则：
/// 1. 非空
/// 2. 长度[3-20]
/// 3. 字符集：禁用特殊字符：% & * ^ ~ '" / \ < > |
/// 4. ToDo：引入安全规则和字典
/// 正则：
/// 返回值：
/// err = null, 正确
/// errIsNull: 空串
/// errTooShort: 太短
/// errTooLong: 太长
/// errInvalidChar: 非法字符
exports.testPassword = function(strPassword, callback) {
    var errCode = null;
    var regExp = /^[^%\*\^~\'\"\/\\\<\>\|]+$/g;

    if (strPassword.length == 0) {
        // 不能为空
        errCode = 'errIsNull';
    } else if (strPassword.length < 3) {
        // 长度：过短
        errCode = 'errTooShort';
    } else if (strPassword.length > 20) {
        // 长度：过长
        errCode = 'errTooLong';
    } else if (!regExp.test(strPassword)) {
        // 长度：非法字符，使用正则表达式匹配
        errCode = 'errInvalidChar';
    }

    return callback(errCode);
};