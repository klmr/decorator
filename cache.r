decorate = modules::import('decorate', attach = TRUE)
modules::import('ebits/base', attach = c('closure', 'match_call_defaults'))

cache = decorator %@% function (f) {
    cache = new.env()
    g = function (...) {
        call = match_call_defaults()
        args = call[-1]
        # Use a helper to evaluate all arguments in their proper scope.
        calling_args = `[[<-`(call, 1, function (...) list(...))
        args_hash = if (is.null(args)) '.' else
            paste(lapply(eval.parent(calling_args), hash), collapse = ', ')
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
