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

print.decorator = function (x, ...) {
    fun_def = gsub('^function', 'decorator', capture.output(print.function(x)))
    # Remove attributes, in particular `class`
    attr_index = grep('^attr\\(,"class"\\)$', fun_def)
    fun_def = fun_def[1 : attr_index - 1]
    cat(fun_def, sep = '\n')
    invisible(x)
}

modules::register_S3_method('print', 'decorator', print.decorator)

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
