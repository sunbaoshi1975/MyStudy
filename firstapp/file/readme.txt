当读取文件出现错误时，err 将会是 Error 对象。如果 readme.txt 不存在，运行前面的代码则会出现以下结果：
{ [Error: ENOENT, no such file or directory 'readme.txt'] errno: 34, code: 'ENOENT', path: 'readme.txt' }