
/*
 * GET home page.
 */
var crypto = require('crypto');
var User = require('../models/user.js');
var Post = require('../models/post.js');
var inputValid = require('../mypackage/inputValidation.js');

module.exports = function(app) {
    app.get('/', function(req, res) {
        Post.get(null, function(err, posts) {
            if (err) {
                posts = [];
            }
            res.render('index', {
                title: 'Home',
                posts: posts
            });
        });
    });

    app.get('/reg', checkNotLogin);
    app.get('/reg', function(req, res) {
        res.render('reg', {
            title: '用户注册'
        });
    });

    app.post('/reg', checkNotLogin);
    app.post('/reg', function(req, res) {
        // 验证用户名有效性
        inputValid.testUsername(req.body['username'], function(err) {
            if (err) {
                switch (err) {
                    case 'errIsNull':
                    case 'errTooShort':
                        req.flash('error', '用户名不能为空或者太短（不少于3位字符）');
                        break;
                    case 'errTooLong':
                        req.flash('error', '用户名过长（不超过20位字符）');
                        break;
                    case 'errInvalidStart':
                        req.flash('error', '用户名必须以字母开头');
                        break;
                    case 'errInvalidChar':
                        req.flash('error', '用户名只能使用字母、数字和下划线');
                        break;
                    default:
                        req.flash('error', '未知错误');
                        break;
                }
                req.flash('username', '');
                return res.redirect('/reg');
            }

            // 设置临时数据，用于页面刷新时显示
            req.flash('username', req.body['username']);

            // 检验用户两次输入的口令是否一致
            if (req.body['password-repeat'] != req.body['password']) {
                req.flash('error', '两次输入的密码不一致');
                return res.redirect('/reg');
            }
            // 验证口令有效性
            inputValid.testPassword(req.body['password'], function(err) {
                if (err) {
                    switch (err) {
                        case 'errIsNull':
                        case 'errTooShort':
                            req.flash('error', '口令不能为空或者少于3位字符');
                            break;
                        case 'errTooLong':
                            req.flash('error', '口令过长（不超过20位字符）');
                            break;
                        case 'errInvalidChar':
                            req.flash('error', '口令包括非法字符');
                            break;
                        default:
                            req.flash('error', '未知错误');
                            break;
                    }
                    return res.redirect('/reg');
                }

                // 生成口令的散列值
                var md5 = crypto.createHash('md5');
                var password = md5.update(req.body.password).digest('base64');

                var newUser = new User({
                    name: req.body.username,
                    password: password
                });

                // 检查用户名是否已经存在
                User.get(newUser.name, function(err, user) {
                    if (user)
                        err = 'Username already exists.';
                    if ( err ) {
                        req.flash('error', err);
                        return res.redirect('/reg');
                    }

                    // 如果不存在则新增用户
                    newUser.save(function(err) {
                        if ( err ) {
                            req.flash('error', err);
                            return res.redirect('/reg');
                        }
                        req.session.user = newUser;
                        req.flash('success', '注册成功');
                        res.redirect('/');
                    });
                });
            });
        });
    });

    app.get('/login', checkNotLogin);
    app.get('/login', function(req, res) {
        res.render('login', {
            title: '用户登入'
        });
    });

    app.post('/login', checkNotLogin);
    app.post('/login', function(req, res) {
        // 生成口令的散列值
        var md5 = crypto.createHash('md5');
        var password = md5.update(req.body.password).digest('base64');

        User.get(req.body.username, function(err, user) {
            if (!user) {
                req.flash('username', '');
                req.flash('error', 'user not exist');
                return res.redirect('/login');
            }
            if (user.password != password) {
                // 设置临时数据，用于页面刷新时显示
                req.flash('username', req.body.username);
                req.flash('error', 'password wrong');
                return res.redirect('/login');
            }
            req.session.user = user;
            req.flash('success', '登入成功');
            res.redirect('/');
        });
    });

    app.get('/logout', checkLogin);
    app.get('/logout', function(req, res) {
        req.session.user = null;
        req.flash('success', '登出成功');
        res.redirect('/');
    });

    app.post('/post', checkLogin);
    app.post('/post', function(req, res) {
        var currentUser = req.session.user;
        var post = new Post(currentUser.name, req.body.post);
        post.save(function(err) {
            if (err) {
                req.flash('error', err);
                return res.redirect('/');
            }
            req.flash('success', '发表成功');
            res.redirect('/u/' + currentUser.name);
        });
    });

    // 微博不需要控制阅读权限
    //app.get('/u/:user', checkCurrentUser);
    app.get('/u/:user', function(req, res) {
        User.get(req.params.user, function(err, user) {
            if (!user) {
                req.flash('error', '用户不存在');
                return res.redirect('/');
            }
            Post.get(user.name, function(err, posts) {
                if (err) {
                    req.flash('error', err);
                    return res.redirect('/');
                }
                res.render('user', {
                    title: user.name,
                    posts: posts
                });
            });
        });
    });
};

function checkLogin(req, res, next) {
    if (!req.session.user) {
        req.flash('error', 'Not Logged On');
        return res.redirect('/login');
    }
    next();
}

function checkNotLogin(req, res, next) {
    if (req.session.user) {
        req.flash('error', 'Already logged on');
        return res.redirect('/');
    }
    next();
}

function checkCurrentUser(req, res, next) {
    if (!req.session.user) {
        req.flash('error', 'Not Logged On');
        return res.redirect('/login');
    } else if (req.session.user.name != req.params.user) {
        req.flash('error', 'Cannot view other user contents');
        return res.redirect('/');
    }
    next();
}