`%@%` = function (decorator, f) UseMethod('%@%')

`%@%.default` = function (decorator, f)
    stop(deparse(substitute(decorator)), ' is not a decorator')

`%@%.decorator` = function (decorator, f) {
    # Handle operator precedence so that we can chain decorators.
    if (inherits(f, 'decorator'))
        .delayed_decorate(decorator, f)
    else
        prettify(decorator(f), f)
}

decorator = function (f)
    structure(f, class = 'decorator')

decorator = decorator(decorator)


prettify = function (f, original) {
    attr(f, 'srcref') = pretty_code(original)
    f
}

pretty_code = function (f) {
    srcref = attr(f, 'srcref')
    if (is.null(srcref)) body(f) else srcref
}

.delayed_decorate = function (d1, d2)
    decorator(function (f) d1(d2(f)))
