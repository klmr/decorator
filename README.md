## R function decorators

A “decorator” is a function that wraps another function. This allows creating
new functions effortlessly, and is a powerful tool to add functionality to
functions as soon as they are defined.

For instance, let’s say we want a given function to be always called twice. This
can of course be achieved easily by just executing the function body twice (for
instance in a loop). However, a better way would be to just *tell* the function
“hey, execute twice”; so that, when the function is called, it is automatically
executed twice:

```r
echo = function (msg)
    message(msg)

echo('hi')
# Desired output:
# hi
# hi
```

Since functions are objects in R and can be passed to other functions, we can
“tell” `echo` to execute twice by modifying it:

```r
echo = twice(echo)
```

Now we just need to define `twice`, which takes a function and returns a new
function that calls the original function twice, forwarding all its arguments.
However, the above is somewhat cumbersome because we first need to define `echo`
and then modify it.

Alternatively, wrapping the original definition inside a function call works but
becomes unreadable — especially once the function becomes longer:

```r
echo = twice(
    function (msg)
        message(msg)
)
```

Now consider that we may wrap the function inside *multiple* other functions.
Even worse. The “decorators” module allows us to write the following instead:

```r
echo = twice %@% function (msg)
    message(msg)
```

A more realistic example might be a `logged` function that causes a function to
be logged. Decorators can be chained, so we might write:

```r
echo = logged('log.txt') %@% twice %@% function (msg)
    message(msg)
```

For comparison, in Python this would be written as

```python
@logged('log.txt')
@twice
def echo(msg):
    print(msg)
```

The implementation of the decorator `twice` is trivial:

```r
#' Call decorated function twice, in succession
twice = decorator %@% function (f) {
    function (...) {
        f(...)
        f(...)
    }
}
```

`twice` is a normal function that takes a function and returns a different
function (which, when called, calls `f` twice). The only thing that’s special
about `twice` is that it’s itself decorated by the `decorator` function.
`decorator` makes a decorator out of a regular function.¹

`logged` is only slightly more complex:

```r
#' Log each call to the decorated function
logged = function (filename) decorator %@% function (f) {
    function (...) {
        cat(deparse(match.call()), file = filename, append = TRUE)
        f(...)
    }
}
```

The “decorators” module takes care of pretty-printing decorated functions to
hide the uninteresting decorator wrappers. Instead, the original function body
is shown, along with the declared decorators (as one might expect intuitively):

```r
print(echo)
# logged("log.txt") %@%
# twice %@%
# function (msg)
#     message(msg)
# <environment: 0x7fd7d4f6a3c0>
```

> ¹ The `decorator` decorator is necessary to allow easy chaining of decorators.

### The `cache` decorator

The `cache` decorator causes a function to cache its results: calling the
function again with the same arguments returns the cached result without
re-executing the function. This is useful when re-calculating the results is
significantly more expensive than maintaining and querying a cache.

This can also be used to elegantly (if somewhat inefficiently) implement dynamic
programming algorithms. Consider this implementation of the Fibonacci numbers:

```r
fib = cache %@% function (n) if (n < 2) 1 else fib(n - 1) + fib(n - 2)
```

This function has roughly linear runtime and is thus asymptotically more
efficient than a naive recursive implementation (i.e. the same implementation
without caching), which has exponential runtime.

### Rationale

Computations on functions can be very useful and fit easily into the concept of
R programming, since R treats functions as proper first-class objects and
provides powerful introspection and metaprogramming capabilities. However, until
now, systematically applying modifications to functions as soon as they are
declared was syntactically not trivial. The decorator syntax encourages more
widespread use of function modifications.

The concept of R function decorators is based on [Python function decorators][],
which also inspired the syntax. The syntax is designed to be as unobtrusive as
possible, and to blend into the normal function declaration syntax.

[Python function decorators]: https://www.python.org/dev/peps/pep-0318/
