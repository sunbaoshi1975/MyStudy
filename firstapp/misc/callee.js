/**
 * Created by sunboss on 2014/8/4.
 */
function factorial(n) {
    if (n <= 0) {
        console.log('finished step %d', n)
        return 1;
    }
    else {
        console.log('step %d: %d * func(%d)', n, n, n-1);
        return n * arguments.callee(n - 1);
    }
}

console.log(factorial(5));