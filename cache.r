decorate = modules::import('decorate', attach = TRUE)
modules::import('ebits/base', attach = c('closure', 'match_call_defaults'))

# FIXME: Doesn’t work with recursive functions
# Reproduce: fib = .cache %@% function (n) if (n < 2) 1 else fib(n - 1) + fib(n - 2)
# Suspicion: somehow, the state of the function is shared, and `n` is
# continuously decreased. But only sometimes.
cache = decorator %@% function (f) {
    cache = new.env()
    g = function (...) {
        call = match_call_defaults()
        args = call[-1]
        args_hash = if (is.null(args)) '.' else
            paste(sapply(lapply(args, eval.parent), hash), collapse = ', ')
        if (exists(args_hash, cache))
            cache[[args_hash]]
        else {
            call[[1]] = f
            result = eval.parent(call)
            cache[[args_hash]] <<- result
            result
        }
    }
    closure(formals(f), body(g), environment())
}

`%@%` = decorate$`%@%`

hash = function (obj) UseMethod('hash')

hash.default = function (obj) deparse(obj)

hash.environment = function (obj) hash(as.list(obj))

hash.NULL = function (obj) 'NULL'

hash.function = function (obj)
    paste(deparse(obj), capture.output(environment(obj)))
